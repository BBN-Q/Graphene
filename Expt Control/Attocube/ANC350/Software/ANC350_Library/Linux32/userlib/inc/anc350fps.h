/*****************************************************************************
 *
 *  Project:        ANC350 Custom Programming Library
 *
 *  Filename:       anc350fps.h
 *
 *  Author:         NHands GmbH & Co KG
 */
/*****************************************************************************/
/** @file anc350fps.h
 *
 *  @brief Control functions for ANC350FPS
 *
 *  Defines additional functions for controlling the ANC350FPS.
 *  All common functions from @ref anc350res.h also apply to the ANC350FPS.
 *  The functions are not thread safe!
 */
/*****************************************************************************/
/* $Id: anc350fps.h,v 1.1 2016/05/04 12:00:06 trurl Exp $ */

#ifndef __ANC350FPS_H__
#define __ANC350FPS_H__

#include "ancdecl.h"
#include "anc350res.h"


/** @brief Reset Position
 *
 *  Sets the current (relative) position of an axis to Zero.
 *  Only applicable for ANC350FPS (and ANC350NUM).
 *  @param  device     Handle of the device to access
 *  @param  axisNo     Axis number (0 ... 2)
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_resetPosition( ANC_Handle device,
                                       Uit32      axisNo );

#endif 

