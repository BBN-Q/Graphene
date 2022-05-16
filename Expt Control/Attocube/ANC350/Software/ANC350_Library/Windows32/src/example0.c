/*******************************************************************************
 *
 *  Project:        ANC350 Custom Programming Library
 *
 *  Filename:       example0.c
 *
 *  Purpose:        Trivial application example
 *
 *  Author:         NHands GmbH & Co KG
 *
 *******************************************************************************/
/* $Id: example0.c,v 1.4 2015/10/15 16:43:12 trurl Exp $ */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifdef unix
#include <unistd.h>
#define Sleep(ms) usleep(ms*1000)
#else
#include <windows.h>
#endif
#include "anc350res.h"
#include "anc350num.h"

#define ON    1  /* for Bln32 */
#define OFF   0
#define DEVNO 0  /* Device and axis to use */
#define AXIS  0  

static void checkError( Int32 code )
{
  switch ( code ) {
  case ANC_Ok:            return;
  case ANC_Error:         printf( "Error: unspecific\n" );             break;
  case ANC_Timeout:       printf( "Error: communication timeout\n" );  break;
  case ANC_NotConnected:  printf( "Error: not connected\n" );          break;
  case ANC_DriverError:   printf( "Error: driver error\n" );           break;
  case ANC_DeviceLocked:  printf( "Error: device locked\n" );          break;
  case ANC_NoDevice:      printf( "Error: invalid device number\n" );  break;
  case ANC_NoAxis:        printf( "Error: invalid axis number\n" );    break;
  case ANC_OutOfRange:    printf( "Error: parameter out of range\n" ); break;
  case ANC_NotAvailable:  printf( "Error: Function not available\n" ); break;
  default:                printf( "Error: unknown\n" );
  }
  exit( 1 );
}

static const char * printDevType( ANC_DeviceType tp )
{
  switch ( tp ) {
  case Anc350Res:  return "ANC350RES";
  case Anc350Num:  return "ANC350NUM";
  case Anc350Fps:  return "ANC350FPS";
  default:;
  }
  return "-invalid-";
}


/* Special tests for ANC350NUM */
static void anc350NumTests( ANC_Handle handle )
{
  Int32 rc;
  double pos, ref;
  Bln32 valid;
  rc = ANC_getPosition( handle, AXIS, &pos );
  checkError( rc );
  rc = ANC_getRefPosition( handle, AXIS, &ref, &valid );
  checkError( rc );
  printf( "NUM Test: Pos=%10.3fum, ref=%10.3fum, valid=%d\n", pos, ref, valid );
  rc = ANC_resetPosition( handle, AXIS );
  checkError( rc );
  rc = ANC_getPosition( handle, AXIS, &pos );
  checkError( rc );
  printf( "NUM-Test: Pos=%10.3fum, ref=%10.3fum, valid=%d\n", pos, ref, valid );
}


int main( int argc, char ** argv )
{
  Int32 rc;
  Uit32 i, devCount;
  double ampl, freq, pos, cap;
  ANC_Handle handle;
  ANC_DeviceType devType;
  Bln32 backward = 0;

  if ( argc > 1 && !strcmp( argv[1], "bwd" ) ) {
    backward = 1;
  }

  rc = ANC_discover( IfAll, &devCount );
  checkError( rc );
  printf( "%d devices found.\n", devCount );
  for ( i = 0; i < devCount; ++i ) {
    Int32 devId;
    Bln32 conn;
    Int8  serial[20];
    rc = ANC_getDeviceInfo( i, &devType, &devId, serial, NULL, &conn );
    checkError( rc );
    printf( "  Type=%s ID=%d, connected=%s serial=%s\n",
            printDevType( devType ), devId, conn ? "yes" : "no ", serial );
  }

  printf( "Using device %d, axis %d\n", DEVNO, AXIS );
  rc = ANC_connect( DEVNO, &handle );
  checkError( rc );
  rc = ANC_setAmplitude(  handle, AXIS, 30. /* 30V */ );
  checkError( rc );
  rc = ANC_setFrequency(  handle, AXIS, 1000. /* 1kHz */ );
  checkError( rc );
  rc = ANC_setAxisOutput( handle, AXIS, ON, OFF );
  checkError( rc );
  rc = ANC_getAmplitude(  handle, AXIS, &ampl );
  checkError( rc );
  rc = ANC_getFrequency(  handle, AXIS, &freq );
  checkError( rc );
  printf( "Amplitude: %.1fV (should be 30V), Frequency: %.1fHz (should be 1kHz)\n", ampl, freq );

  rc = ANC_measureCapacitance(  handle, AXIS, &cap );
  checkError( rc );
  printf( "Capacitance: %.3fnF\n", cap * 1.e9 );

  if ( devType == Anc350Num ) {
    for ( i = 0; i < 10; ++i ) {
      Sleep( 10 );
      anc350NumTests( handle );
    }
  }

  rc = ANC_startContinousMove( handle, AXIS, ON, backward );
  checkError( rc );
  for ( i = 0; i < 20; ++i ) {
    Bln32 conn, enab, move, eotf, eotb, err;
    rc = ANC_getPosition(   handle, AXIS, &pos );
    checkError( rc );
    rc = ANC_getAxisStatus( handle, AXIS, &conn, &enab, &move, NULL, &eotf, &eotb, &err );
    checkError( rc );
    printf( "Pos=%10.3fum, conn=%d, ena=%d, move=%d, eotFwd=%d, eotBwd=%d, error=%d\n",
            pos * 1.e6, conn, enab, move, eotf, eotb, err );
    Sleep( 50 );
  }

  rc = ANC_startContinousMove( handle, AXIS, OFF, OFF );
  checkError( rc );
  rc = ANC_setAxisOutput( handle, 0, OFF, OFF );
  checkError( rc );
  rc = ANC_disconnect( handle );
  checkError( rc );
  return 0;
}
