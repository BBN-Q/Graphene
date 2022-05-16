/*****************************************************************************
 *
 *  Project:        ANC350 Custom Programming Library
 *
 *  Filename:       anc350num.h
 *
 *  Author:         NHands GmbH & Co KG
 */
/*****************************************************************************/
/** @file anc350num.h
 *
 *  @brief Control functions for ANC350NUM
 *
 *  Defines additional functions for controlling the ANC350NUM.
 *  All common functions from @ref anc350res.h also apply to the ANC350NUM.
 *  The functions are not thread safe!
 */
/*****************************************************************************/
/* $Id: anc350num.h,v 1.2 2016/05/04 12:00:06 trurl Exp $ */

#ifndef __ANC350NUM_H__
#define __ANC350NUM_H__

#include "ancdecl.h"
#include "anc350res.h"


/** @brief Reset Position
 *
 *  Sets the current (relative) position of an axis to Zero.
 *  Only applicable for ANC350NUM (and ANC350FPS).
 *  @param  device     Handle of the device to access
 *  @param  axisNo     Axis number (0 ... 2)
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_resetPosition( ANC_Handle device,
                                       Uit32      axisNo );


/** @brief Reset Reference
 *
 *  Starts an approach to the reference position. A running motion command is aborted;
 *  automatic moving (see @ref ANC_startAutoMove) is switched on. Requires a valid
 *  reference position.
 *  Only applicable for ANC350NUM.
 *  @param  device     Handle of the device to access
 *  @param  axisNo     Axis number (0 ... 2)
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_moveReference( ANC_Handle device,
                                       Uit32      axisNo );


/** @brief Read Reference Position
 *
 *  Retrieves the current reference position.
 *  For linear type actuators the position unit is m; for goniometers and
 *  rotators it is degree.
 *  Only applicable for ANC350NUM.
 *  @param  device     Handle of the device to access
 *  @param  axisNo     Axis number (0 ... 2)
 *  @param  position   Output: Current reference position [m] or [°]
 *  @param  valid      Output: If the reference position is valid
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_getRefPosition( ANC_Handle device,
                                        Uit32      axisNo,
                                        double   * position,
                                        Bln32    * valid );


/** @brief Configure Duty Cycle Parameters
 *
 *  Enables and configures the sensor's duty cycle for all axes.
 *  Requires the duty cycle feature to be installed.
 *  Only applicable for ANC350NUM.
 *  @param  device     Handle of the device to access
 *  @param  enable     Enable or disable the duty cycle
 *  @param  period     Duty cycle period [s]
 *  @param  offTime    Duty cycle off time [s]
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_configureDutyCycle( ANC_Handle device,
                                            Bln32      enable,
                                            double     period,
                                            double     offTime );


/** @brief Switch Sensor Power
 *
 *  Switches the sensor power for all axes on or off.
 *  Only applicable for ANC350NUM.
 *  @param  device     Handle of the device to access
 *  @param  enable     Enable or disable the sensor
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_enableSensor( ANC_Handle device,
                                      Bln32      enable );


/** @brief Enable Reference Auto Update
 *
 *  Enables or disables the reference auto update for an axis.
 *  When enabled, every time the reference marking is hit, the reference
 *  position will be updated. When disabled, the reference marking will
 *  be considered only the first time, later hits will be ignored.
 *  Only applicable for ANC350NUM.
 *  @param  device     Handle of the device to access
 *  @param  axisNo     Axis number (0 ... 2)
 *  @param  enable     Enable or disable the feature
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_enableRefAutoUpdate( ANC_Handle device,
                                             Uit32      axisNo,
                                             Bln32      enable );


/** @brief Enable Position Auto Reset
 *
 *  Enables or disables the position auto reset for an axis.
 *  When enabled, every time the reference marking is hit, the position
 *  will be set to zero. When disabled, the reference marking will be ignored.
 *  Only applicable for ANC350NUM.
 *  @param  device     Handle of the device to access
 *  @param  axisNo     Axis number (0 ... 2)
 *  @param  enable     Enable or disable the feature
 *  @return            Error code
 */
ANC_API Int32 WINCC ANC_enableRefAutoReset( ANC_Handle device,
                                            Uit32      axisNo,
                                            Bln32      enable );

#endif 

