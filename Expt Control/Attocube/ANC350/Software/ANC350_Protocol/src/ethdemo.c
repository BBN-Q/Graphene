/*******************************************************************************/
/*
 *  Project:        ANC350xxx
 *
 *  Filename:       ethdemo.cpp
 *
 *  Purpose:        Protocol usage demo over TCP/IP
 *
 *  Author:         G. Franke,  g.franke@n-hands.de
 *
 *  Comment:        Compilation commands:
 *                    Windows with Visual Studio: "cl  ethdemo.c ws2_32.lib"
 *                    Windows with minGW32:       "gcc ethdemo.c -l ws2_32 -o ethdemo.exe"
 *                    Linux with GCC:             "gcc ethdemo.c -o ethdemo"
 */
/*******************************************************************************/
/* $Id: ethdemo.c,v 1.1 2015/08/21 16:23:39 trurl Exp $ */

#ifdef unix
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#define closesocket close
#define SET_INADDR(in_var,adr_val)  (in_var) .s_addr = (adr_val)
#define GET_INADDR(in_var)          (in_var) .s_addr

#else

#include <windows.h>
#define SET_INADDR(in_var,adr_val)  (in_var) .S_un .S_addr = (adr_val)
#define GET_INADDR(in_var)          (in_var) .S_un .S_addr
typedef struct fd_set fd_set;
#define usleep(x) Sleep((x)/1000)
#endif

#include <stdio.h>
#include "ucprotocol.h"
#include "anc350res_protocol.h"


/* ---------------------------------------------------
** Networking helper functions
** ---------------------------------------------------
*/

static void tcpInit()
{
#ifndef unix
  static int winsockInit = 0;
  if ( !winsockInit ) {
    WORD wVersionRequested = MAKEWORD( 2, 2 );
    WSADATA wsaData;
    WSAStartup( wVersionRequested, &wsaData );
    winsockInit = 1;
  }
#endif
}


static int tcpConnect( unsigned long host, unsigned short port )
{
  int sk;
  struct sockaddr_in adr;
  adr .sin_family  = AF_INET;
  adr .sin_port    = htons( port );
  SET_INADDR( adr .sin_addr, host );
  sk = (int) socket( PF_INET, SOCK_STREAM, 0 );
  if ( sk <= 0 ) {
    fprintf( stderr, "Connect to controller: socket() failed" );
    return -1;
  }

  if ( connect( sk, (struct sockaddr *) &adr, sizeof( struct sockaddr_in ) ) < 0 ) {
    fprintf( stderr, "Connect to controller: connect() failed" );
    closesocket( sk );
    return -1;
  }
  return sk;
}


static int tcpConnectByName( const char * host, unsigned short port )
{
  struct hostent * hp = gethostbyname( host );
  if ( !hp ) {
    fprintf( stderr, "Connect to controller: gethostbyname() failed" );
    return -1;
  }

  return tcpConnect( * (unsigned long *) (hp ->h_addr), port );
}


static void tcpDisconnect( int sock )
{
  closesocket( sock );
}


static int tcpReceive( int sock, int timeout, UcTelegram * buf )
{
  int bytes = 1, received = 0, selrc = 0, expected = sizeof( Int32 );
  fd_set  fds;
  struct timeval to;
  FD_ZERO( &fds );
  FD_SET( sock, &fds );
  to .tv_sec  = timeout / 1000;
  to .tv_usec = (timeout % 1000) * 1000;

  selrc = select( sock + 1, &fds, 0, 0, &to );

  if ( selrc > 0 ) {
    while ( expected > received && bytes > 0 ) {
      bytes     = recv( sock, (char*) buf + received, expected - received, 0 );
      received += bytes;
      if ( received == sizeof( Int32 ) ){
        expected = sizeof( Int32 ) + * (Int32*) buf;  /* Length has been received */
        if (expected > UC_MAXSIZE){
          fprintf( stderr, "Receive from controller: Telegram too long" );
          return -2;
        }
      }
    }

    if ( bytes <= 0 ) {
      fprintf( stderr, "Receive from controller: recv() failed" );
      received = -1;
    }
  }
  else if ( selrc < 0 ) {
    fprintf( stderr, "Receive from controller: select() failed" );
    received = -1;
  }

  return received;
}


static int tcpSend( int socket, Int32 length, void * data )
{
  int rc = send( socket, (char*) data, length, 0 );
  if ( rc != length ) {
    fprintf( stderr, "Send to controller: send() failed" );
    return -1;
  }
  return 0;
}


/* ---------------------------------------------------
** Protocol support
** ---------------------------------------------------
*/

#define ANC_TCP_PORT     2101
#define RECV_TIMEOUT     1000
#define TEST_CTAG        0x99

/* Send a set telegram without requesting an ack */
static int protoSet( int socket, Int32 addr, Int32 index, Int32 value )
{
  UcSetTelegram command = { {
      sizeof( UcSetTelegram ) - sizeof( Int32 ), /* length */
      UC_SET,                                    /* opcode */
      addr,                                      /* address */
      index,                                     /* index */
      0                                          /* No corr. # */
    }, {
      value                                      /* data[0] */
    } };
  int rc = tcpSend( socket, sizeof( UcSetTelegram ), &command );
  if ( rc ) {
    fprintf( stderr, "\nprotoSet failed for addr %x\n", addr );
  }
  return rc;
}


/* Check the reason code of an ack telegram */
static int checkReason( UcAckTelegram * ack )
{
  int rc = 0;
  if ( ack ->reason != UC_REASON_OK ) {
    fprintf( stderr, "\nReceived bad reason code %d on addr %x.\n",
             ack ->reason, ack ->hdr .address );
    rc = -1;
  }
  return rc;
}


/* Listen for telegrams until a correlation number or address/index is matched */
static int protoListen( int socket, Int32 corr, Int32 addr, Int32 index, Int32 * value )
{
  int ok = 1, received = 0;
  char buffer[UC_MAXSIZE];
  UcTelegram     * answer = (UcTelegram *)     buffer;
  UcAckTelegram  * ack    = (UcAckTelegram *)  buffer;
  UcTellTelegram * tell   = (UcTellTelegram *) buffer;

  while ( ok && !received ) {
    int size = tcpReceive( socket, RECV_TIMEOUT, answer );
    ok = size >= 0;
    if ( ok && size != sizeof( UcAckTelegram ) && size != sizeof( UcTellTelegram ) ) {
      fprintf( stderr, "\nReceived wrong size: %d.\n", size );
      ok = 0;
    }

    // Received ack with matching correlation number (if given)
    if ( ok && corr != 0 && answer ->opcode == UC_ACK && answer ->correlationNumber == corr ) {
      received = 1;
      ok       = !checkReason( ack );
      *value   = ack ->data[0];
    }

    // Received ack or event with matching address (if no corr.no. given)
    if ( ok && corr == 0 && answer ->address == addr && answer ->index == index ) {
      received = 1;
      if ( answer ->opcode == UC_ACK ) {
        *value = ack ->data[0];
        ok = !checkReason( ack );
      }
      else { /* must be UC_TELL */
        *value = tell ->data[0];
      }
    }
  }
  if ( !ok ) {
    fprintf( stderr, "\nprotoListen failed for corr/addr %d/%x\n", corr, addr );
  }
  return !ok;
}


/* Send a get telegram and wait for the answer */
static int protoGet( int socket, Int32 addr, Int32 index, Int32 * value )
{
  int rc = 0;
  UcGetTelegram request = { {
      sizeof( UcGetTelegram ) - sizeof( Int32 ), /* length */
      UC_GET,                                    /* opcode */
      addr,                                      /* address */
      index,                                     /* index */
      TEST_CTAG                                  /* corr. # */
    } };
  rc = tcpSend( socket, sizeof( UcGetTelegram ), &request );
  if ( !rc ) {
    rc = protoListen( socket, TEST_CTAG, 0, 0, value );
  }
  return rc;
}


/* ---------------------------------------------------
** ANC350 Demo
** ---------------------------------------------------
*/

#define TEST_AMPLITUDE    30000 /* 30V */
#define TEST_FREQUENCY     2000 /* 2kHz */
#define TEST_AXIS             0 /* Axis 0 */
#define TEST_TARGET     1000000 /* 1mm */

int main( int argc, char ** argv )
{
  int ok = 1, i = 0, reached = 0;
  int socket = 0;

  if ( argc < 2 ) {
    fprintf( stderr, "\nusage: %s <Ip-Address>\n\n", argv[0] );
    ok = 0;
  }

  if ( ok ) {
    tcpInit();
    socket = tcpConnectByName( argv[1], ANC_TCP_PORT );
    ok = socket > 0;
  }

  /* A first connection test */
  if ( ok ) {
    Int32 hwId = 0;
    ok = !protoGet( socket, ID_GET_HW_ID, 0, &hwId );
    printf( "HwId: success=%d, value=%x\n", ok, hwId );
  }

  /* Set some positioning parameters */
  if ( ok ) ok = !protoSet( socket, ID_ANC_OUTPUT_EN,    TEST_AXIS, 1 );
  if ( ok ) ok = !protoSet( socket, ID_ANC_AMPL,         TEST_AXIS, TEST_AMPLITUDE );
  if ( ok ) ok = !protoSet( socket, ID_ANC_FAST_FREQ,    TEST_AXIS, TEST_FREQUENCY );

  /* Start automatic move 1 mm forward */
  if ( ok ) ok = !protoSet( socket, ID_ANC_TARGET,       TEST_AXIS, TEST_TARGET );
  if ( ok ) ok = !protoSet( socket, ID_ANC_RUN_RELATIVE, TEST_AXIS, 1 );

  /* Monitor position */
  for ( i = 0; ok && !reached && i < 100; ++i ) {
    int position = 0;
    ok = !protoListen( socket, 0, ID_ANC_POSITION, TEST_AXIS, &position )
      && !protoGet( socket, ID_ANC_TARGET_STATUS, TEST_AXIS, &reached );
    printf( "Position=%d, Reached=%d, Ok=%d\n", position, reached, ok );
  }

  /* stop (unconditional) */
  protoSet( socket, ID_ANC_RUN_RELATIVE, TEST_AXIS, 0 );
  protoSet( socket, ID_ANC_OUTPUT_EN,    TEST_AXIS, 0 );

  return !ok;
}
