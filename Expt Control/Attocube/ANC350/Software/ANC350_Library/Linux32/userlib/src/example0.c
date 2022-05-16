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
/* $Id: example0.c,v 1.7 2019/02/18 09:46:55 trurl Exp $ */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
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


static int timestamp()
{
#ifdef unix
  static time_t zero = time( 0 );  // statischer Nullpunkt (Programmstart)
  struct timeval tv;
  gettimeofday( &tv, 0 );
  return (tv .tv_sec - zero) * 1000 + (tv .tv_usec / 1000 );
#else
  static int zero = 0;
  if ( !zero ) {
    zero = GetTickCount();
  }
  return GetTickCount() - zero;
#endif
}


static void printx( const char * format, ... )
{
  va_list args;
  va_start( args, format );
  printf( "%5d: ", timestamp() );
  vprintf( format, args );
}


static void checkError( Int32 code )
{
  switch ( code ) {
  case ANC_Ok:            return;
  case ANC_Error:         printx( "Error: unspecific\n" );               break;
  case ANC_Timeout:       printx( "Error: communication timeout\n" );    break;
  case ANC_NotConnected:  printx( "Error: not connected\n" );            break;
  case ANC_DriverError:   printx( "Error: driver error\n" );             break;
  case ANC_DeviceLocked:  printx( "Error: device locked\n" );            break;
  case ANC_NoDevice:      printx( "Error: invalid device number\n" );    break;
  case ANC_NoAxis:        printx( "Error: invalid axis number\n" );      break;
  case ANC_OutOfRange:    printx( "Error: parameter out of range\n" );   break;
  case ANC_NotAvailable:  printx( "Error: function not available\n" );   break;
  case ANC_FileError:     printx( "Error: can't open or parse file\n" ); break;
  default:                printx( "Error: unknown\n" );
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


static void testStatusUpdate( ANC_Handle handle, Bln32 backward )
{
  Int32 i, rc;
  printx( "\nTest Status update\n\n" );
  for ( i = 0; i < 25; ++i ) {
    Bln32 conn, enab, move, eotf, eotb, err;
    if ( i == 3 ) {
      printx( "Start move\n" );
      rc = ANC_startContinousMove( handle, AXIS, ON, backward );
      checkError( rc );
    }
    if ( i == 20 ) {
      printx( "Stop move\n" );
      rc = ANC_startContinousMove( handle, AXIS, OFF, OFF );
      checkError( rc );
    }
    if ( i == 10 ) {
      printx( "Axis disable\n" );
      rc = ANC_setAxisOutput( handle, AXIS, OFF, OFF );
      checkError( rc );
    }
    if ( i == 15 ) {
      printx( "Axis enable\n" );
      rc = ANC_setAxisOutput( handle, AXIS, ON, OFF );
      checkError( rc );
    }
    rc = ANC_getAxisStatus( handle, AXIS, &conn, &enab, &move, NULL, &eotf, &eotb, &err );
    checkError( rc );
    printx( "conn=%d, ena=%d, move=%d, eotFwd=%d, eotBwd=%d, error=%d\n",
            conn, enab, move, eotf, eotb, err );
    Sleep( 1 );
  }
  rc = ANC_startContinousMove( handle, AXIS, OFF, OFF );
  checkError( rc );
}


static void testAutoMove( ANC_Handle handle, Bln32 backward, ANC_DeviceType devType )
{
  Int32 i, rc;
  double pos;
  printx( "\nTest DC Voltage\n\n" );
  rc = ANC_setTargetPosition( handle, AXIS, backward ? -100.e-6 : 100.e-6 );  /* 100um */
  checkError( rc );
  rc = ANC_setTargetRange(  handle, AXIS, 3. );
  checkError( rc );
  rc = ANC_setTargetGround( handle, AXIS, OFF );
  checkError( rc );
  rc = ANC_startAutoMove(   handle, AXIS, ON /*enable*/, ON /*relative*/ );
  checkError( rc );
  for ( i = 0; i < 20; ++i ) {
    Bln32 move, eotf, eotb;
    rc = ANC_getAxisStatus( handle, AXIS, NULL, NULL, &move, NULL, &eotf, &eotb, NULL );
    checkError( rc );
    rc = ANC_getPosition(   handle, AXIS, &pos );
    checkError( rc );
    printx( "move=%d, eotFwd=%d, eotBwd=%d, pos=%8.2fum", move, eotf, eotb, pos*1.e6 );
    if ( devType == Anc350Res ) {
      double dcLv;
      rc = ANC_getDcVoltage(  handle, AXIS, &dcLv );
      checkError( rc );
      printf( ", DC=%6.2fV", dcLv );
    }
    printf( "\n" );
    Sleep( 100 );
  }
  rc = ANC_startAutoMove( handle, AXIS, OFF /*enable*/, ON /*relative*/ );
  checkError( rc );
}


int main( int argc, char ** argv )
{
  Int32 rc;
  Uit32 i, devCount;
  ANC_Handle handle;
  ANC_DeviceType devType;
  Bln32 backward = 0;

  if ( argc > 1 && !strcmp( argv[1], "bwd" ) ) {
    backward = 1;
  }

  rc = ANC_discover( IfAll, &devCount );
  checkError( rc );
  printx( "%d devices found.\n", devCount );
  if ( devCount == 0 ) {
    return 1;
  }
  for ( i = 0; i < devCount; ++i ) {
    Int32 devId;
    Bln32 conn;
    Int8  serial[20];
    rc = ANC_getDeviceInfo( i, &devType, &devId, serial, NULL, &conn );
    checkError( rc );
    printx( "  Type=%s ID=%d, connected=%s serial=%s\n",
            printDevType( devType ), devId, conn ? "yes" : "no ", serial );
  }

  printx( "Using device %d, axis %d\n", DEVNO, AXIS );
  rc = ANC_connect( DEVNO, &handle );
  checkError( rc );
  rc = ANC_setAmplitude(  handle, AXIS, 40. /* 40V */ );
  checkError( rc );
  rc = ANC_setFrequency(  handle, AXIS, 1000. /* 1kHz */ );
  checkError( rc );
  rc = ANC_setAxisOutput( handle, AXIS, ON, OFF );
  checkError( rc );

  /* Test getActuatorName / getLutName */
  for ( i = 0; i < 3; ++i ) {
    Int8  name[20];
    rc = ANC_getActuatorName( handle, i, name );
    checkError( rc );
    printx( "Axis %d: Actuator=%s", i, name );
    if ( devType == Anc350Res ) {
      rc = ANC_getLutName( handle, i, name );
      checkError( rc );
      printf( "  LUT=%s", name );
    }
    printf( "\n" );
  }

  testStatusUpdate( handle, backward );
  testAutoMove( handle, !backward, devType );  // move to opposite direction

  rc = ANC_setAxisOutput( handle, 0, OFF, OFF );
  checkError( rc );
  rc = ANC_disconnect( handle );
  checkError( rc );
  return 0;
}
