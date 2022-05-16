/*****************************************************************************
 *
 *  Project:        ANC350RES Custom Programming Library
 *
 *  Filename:       ancdecl.h
 *
 *  Author:         NHands GmbH & Co KG
 */
/*****************************************************************************/
/** @file ancdecl.h
 *  @brief Technical declarations for the DLL interface and basic type defs.
 */
/*****************************************************************************/
/* $Id: ancdecl.h,v 1.1 2015/08/04 19:39:12 trurl Exp $ */

#ifndef __ANCDECL_H
#define __ANCDECL_H

/** @name Technical declarations for the DLL interface
 *  @{
 */
#ifdef __cplusplus
#define EXTC extern "C"                        /**< For use with C++       */
#else
#define EXTC extern                            /**< For use with C         */
#endif

#ifdef unix
#define ANC_API EXTC                           /**< Not required for Unix  */
#define WINCC                                  /**< Not required for Unix  */
#else
#define WINCC        __stdcall                 /**< Calling convention     */
#ifdef  ANC_EXPORTS
#define ANC_API EXTC __declspec(dllexport)     /**< Internal DLL interface */
#else
#define ANC_API EXTC __declspec(dllimport)     /**< External DLL interface */
#endif
#endif
/* @} */


/** @name Portable data types
 *
 *  Because not all relevant compilers support C99 portable types,
 *  we define our own types of well defined byte length here.
 *  double is portable by itself. Bln32 is an integer used as
 *  boolean for the  clarification of interfaces.
 *  @{
 */
#ifdef _MSC_VER
typedef __int8           Int8;     /**< 8  bit signed integer for MSVC    */
typedef __int32          Int32;    /**< 32 bit signed integer for MSVC   */
typedef unsigned __int32 Uit32;    /**< 32 bit unsigned integer for MSVC */
typedef __int32          Bln32;    /**< integer used as boolean          */
#else
#include <inttypes.h>
typedef int8_t           Int8;     /**< 8  bit signed integer for GCC    */
typedef int32_t          Int32;    /**< 32 bit signed integer for GCC    */
typedef uint32_t         Uit32;    /**< 32 bit unsigned integer for GCC  */
typedef int32_t          Bln32;    /**< integer used as boolean          */
#endif
/* @} */


#endif
