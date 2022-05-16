/********************************************************************
 *
 *  Project:        Controller Interface
 *
 *  Filename:       ucprotocol.h
 *
 *  Purpose:        Protocol Elements
 *
 *  Author:         N-Hands GmbH & Co KG
 */
/*******************************************************************/
/** @file ucprotocol.h
 *  @brief Protocol elements for communication with N-Hands devices
 *
 *  Defines types of telegrams and constants for its data fields
 *  for use in the communication protocol of N-Hands devices.
 */
/*******************************************************************/
/* $Id: ucprotocol.h,v 1.1 2013/09/23 13:18:30 trurl Exp $ */

#ifndef __UCPROTOCOL_H
#define __UCPROTOCOL_H


/** @brief Maximum size of a telegram
 *
 *  Maximum size of a telegram including header (with length field) and data,
 *  in bytes.
 */
#define UC_MAXSIZE 512


/** @brief Maximum number of items
 *
 *  Maximum number of 32-bit data items in a telegram.
 */
#define UC_MAXDATA   ((UC_MAXSIZE - sizeof(UcTelegram)) / sizeof(Int32))


/** @name OpCodes
 *
 *  These constants are used to identify the protocol elements and fit to the
 *  opcode field of the @ref UcTelegram "telegram header".
 *  
 *  @{
 */
#define UC_SET    0         /**< Set telegram                                       */
#define UC_GET    1         /**< Get telegram                                       */
#define UC_ACK    3         /**< Ack (acknowledge) telegram                         */
#define UC_TELL   4         /**< Tell (event) telegramm                             */
/* @} */


/** @name Reason codes
 *
 *  These constants are used to notify about errors in the processing of
 *  @ref UcSetTelegram "Set" and @ref UcGetTelegram "Get" telegrams
 *  They are found in the reason field of the @ref UcAckTelegram "Ack Telegram".
 *  
 *  @{
 */
#define UC_REASON_OK      0 /**< All ok                                             */
#define UC_REASON_ADDR    1 /**< Invalid address                                    */
#define UC_REASON_RANGE   2 /**< Value out of range                                 */
#define UC_REASON_IGNORED 3 /**< Telegram was ignored                               */
#define UC_REASON_VERIFY  4 /**< Verify of data failed                              */
#define UC_REASON_TYPE    5 /**< Wrong type of data                                 */
#define UC_REASON_UNKNW  99 /**< unknown error                                      */
/* @} */


/** @brief Basic Type
 *
 *  Type of all data fields of the telegrams.
 */
#ifdef _MSC_VER
typedef __int32 Int32;      /**< 32-Bit Integer for MSVC                            */
#else
#include <inttypes.h>
typedef int32_t Int32;      /**< 32-Bit Integer for GCC                             */
#endif

/** @brief Telegram header
 *
 *  Common header for all telegram types.
 */
typedef struct {
  Int32 length;             /**< Length of the rest(!) of the telegram              */
  Int32 opcode;             /**< Opcode, UC_SET, UC_GET etc.                        */
  Int32 address;            /**< Identifier (name) of the controller object         */
  Int32 index;              /**< Sub-identifier of the object (if applicable)       */
  Int32 correlationNumber;  /**< Identity number for matching the answer            */
} UcTelegram;

/** @brief Set telegram
 *
 *  This telegram sets a value to an object.
 *  In case of a correlationNumber > 0 an acknowledgement is expected.
 */
typedef struct {
  UcTelegram hdr;           /**< Telegram header                                     */
  Int32 data[1];            /**< Data. May have more than 1 element if necessary     */
} UcSetTelegram;

/** @brief Get telegram
 *
 *  This telegram requests a value from a controller object.
 */
typedef struct {
  UcTelegram hdr;           /**< Telegram header                                     */
} UcGetTelegram;

/** @brief Ack telegram
 *
 *  Acknowledges a done or denied set of a value to a controller object or
 *  represents the answer on a request for a value.
 */
typedef struct {
  UcTelegram hdr;           /**< Telegram header                                     */
  Int32 reason;             /**< Error code, UC_REASON...                            */
  Int32 data[1];            /**< Data. May have more than 1 element if necessary     */
} UcAckTelegram;

/** @brief Tell telegram
 *
 *  Spontaneously tells a value change of a controller object.
 */
typedef struct {
  UcTelegram hdr;           /**< Telegram header                                     */
  Int32 data[1];            /**< Data. May have more than 1 element if necessary     */
} UcTellTelegram;


#endif
