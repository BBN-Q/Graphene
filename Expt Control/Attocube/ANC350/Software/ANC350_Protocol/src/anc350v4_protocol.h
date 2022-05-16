/*****************************************************************************
 *
 *  Project:        ANC350V4 Interface
 *
 *  Filename:       anc350v4_protocol.h
 *
 *  Purpose:        Control Protocol Constants for ANC350RES
 *
 *  Author:         NHands GmbH & Co KG
 */
/*****************************************************************************/
/** @file anc350v4_protocol.h
 *  Control Protocol Constants for ANC350
 *
 *  This file defines constants to be used as parameters or parameter limits
 *  for the control protocol of ucprotocol.h .
 *  It is meant as a working C header as well as a documentation for users
 *  of other programming languages.
 *
 *  @note Constants beginning with ID_ are provided for the address field
 *        of the protocol. They are called addresses.
 *        All other constants are meant as values or limits for the data field.
 *
 *  @note Many addresses control a function of a specific axis. In this case
 *        the axis is identified by the index field of the protocol.
 */
/*****************************************************************************/
/* $Id: anc350v4_protocol.h,v 1.2 2018/03/22 16:08:42 trurl Exp $ */

#ifndef __ANC350V4_H
#define __ANC350V4_H


/** @name Global Limits
 *
 *  Resource counts and other addressing limitations.
 *  @{
 */

/** Number of Axes.
 *  Number of axes of the device. The axis number (used in the index field)
 *  has to be smaller than this number.
 */
#define ANC_NUM_AXES               3
/* @} */



/** @name Device Identification
 *
 *  @details Every device provides an number ("Hardware ID") for identification
 *  in a multi device enviroment. This number can be individually programmed
 *  and read back. For programming, it is not sufficient to sent the new number
 *  to the device; it has to be saved to persistent memory explicitly.
 *  @{
 */

/** Retreive Device ID.
 *  A GET on this address retrieves the current hardware identification of the device.
 *  Factory default is -1 (0xFFFFFFFF). Index must be 0; a SET will be rejected.
 */
#define ID_GET_HW_ID          0x0168

/** Set volatile Device ID.
 *  A SET on this address sets the hardware identification number. Index must be 0.
 *  To save this value persistently in the device, use @ref ID_PROGRAM_ID.
 */
#define ID_SET_HW_ID          0x016A

/** Save Device ID persistently.
 *  A SET on this address with the field data set to 0x1234 saves the current
 *  identification number in persistent memory in the device. The value can be overwritten
 *  by @ref ID_SET_HW_ID and saved by @ref ID_PROGRAM_ID any time.
 */
#define ID_PROGRAM_ID         0x016F

/* @} */


/** @name Output Control
 *
 *  @details The following addresses control the output data stream.
 *  @{
 */

/** Synchronisation Request.
 *  A synchronisation request requests an interrupt of all outputs of the
 *  receiver for 2000ms to allow resynchronisation to the data stream.
 *  It is valid for both directions. Index is 0.
 */
#define ID_SYNC_REQUEST       0x000A

/** Enable asynchronous Events.
 *  To increase protocol performance some values (e.g. ID_ANC_COUNTER) 
 *  are sent as cyclic events (Tell telegrams) by the controller.
 *  The async enable telegram globally enables (data=1) or disables (data=0)
 *  all events. After successfully connecting to the device the events
 *  should be enabled.
 */
#define ID_ASYNC_EN           0x0145
/* @} */


/** @name Firmware Version
 *
 *  @details A SET to @ref ID_FIRMWARE_RETR with the value of 1 acts as a command
 *  that causes the device to send the complete firmware information.
 *  The answer is then sent in TELL telegrams using the ID_VER_... and
 *  ID_PRD_... addresses.
 *
 *  The information splits off in the following categories:
 *  @li "Version / Product" The product identification should be always the
 *      same and is of limited concern to the user. The version information
 *      allows a unique identification of the loaded firmware.
 *  @li "DSP / FPGA" The two entities that need firmware files.
 *  @li "Running / Flashed" The running software is already active whereas
 *      the flashed software is stored in persistent memory and will
 *      become active after the next start of the device.
 *
 *  The firmware information consists of strings encoded in ASCII,
 *  each 32 bit item representing a fragment of 4 characters.
 *  The most siginficant 8 bits represent the leftmost character of the
 *  fragment; the index (0 ... 6 at most) determines the position of the
 *  fragment in the string.
 *  @{
 */

/** Request Firmware Information.
 *  This request should be sent as a command (SET). The complex answer comes
 *  in TELL telegramms with ID_VER_... and ID_PRD_... addresses. Index is 0.
 */
#define ID_FIRMWARE_RETR      0x016C

#define ID_VER_DSP1           0x0111 /**< Version of Running DSP firmware.    */
#define ID_VER_FPGA1          0x0117 /**< Version of running FPGA firmware.   */
#define ID_VER_FL_DSP1        0x0240 /**< Version of running DSP firmware.    */
#define ID_VER_FL_FPGA1       0x0246 /**< Version of flashed FPGA firmware.   */
#define ID_PRD_DSP1           0x0112 /**< Product ID of running DSP firmware. */
#define ID_PRD_FPGA1          0x0118 /**< Product ID of running FPGA firmware.*/
#define ID_PRD_FL_DSP1        0x0241 /**< Product ID of flashed DSP firmware. */
#define ID_PRD_FL_FPGA1       0x0247 /**< Product ID of flashed FPGA firmware.*/

/** Legacy Firmware Version - deprecated.
 *
 *  Deprecated, please do not use in new software!
 *  This read-only parameter transports a simple kind of firmware version
 *  that for technical reasons cannot be absolutely unique. It is present
 *  only for the technical compatibility with older control programs.
 */
#define ID_FIRMWARE_VER       0x3038
/* @} */


/** @name Axis related Status Information
 *
 *  @details The following addresses are read only, SET will fail.
 *  They provide information about the current axis states and are sent
 *  periodically by the controller if events are activated by @ref ID_ASYNC_EN.
 *  The values also can be retrieved with GET.
 *  The index field transports the axis number.
 *
 *  The states are sent in individual addresses as well as in a compact
 *  bitfield that is provided for backward compatiblity.
 *  @{
 */

/** Connection Status.
 *  Reflects if the axis is connected to an actuator (1) or not (0).
 */
#define ID_ANC_CONNECTED      0x3002

/** Moving Status.
 *  The status value is 1 as long as the corresponding axis is moving,
 *  0 otherwise.
 */
#define ID_ANC_MOVING         0x302E

/** EOT Forward Status.
 *  The status value is 1 if an end of travel (EOT) condition is detected
 *  when moving forward, 0 otherwise.
 */
#define ID_ANC_HUMP_FWD       0x3039

/** EOT Backward Status.
 *  The status value is 1 if an end of travel (EOT) condition is detected
 *  when moving backward, 0 otherwise.
 */
#define ID_ANC_HUMP_BKWD      0x303A

/** Sensor Error Status.
 *  Reflects if a sensor error has ocurred (1) or not (0).
 */
#define ID_ANC_SENSOR_ERROR   0x3031

/** Overcurrent Error Status.
 *  Reflects if the axis is switched off due to the detection
 *  of overcurrent (1) or not (0).
 */
#define ID_ANC_IMAX_STATUS    0x3150

/** Compact Status Report.
 *  This address is provided for backward compatibility.
 *  The data field contains the axis states encoded as
 *  a bit field; bit masks are ANC_STATUS_...
 */
#define ID_ANC_STATUS         0x0404

#define ANC_STATUS_RUNNING    0x0001 /**< ANC_STATUS Bitmask: axis is moving. */
#define ANC_STATUS_HUMP       0x0002 /**< ANC_STATUS Bitmask: EOT detected.   */
#define ANC_STATUS_SENS_ERR   0x0100 /**< ANC_STATUS Bitmask: sensor error.   */
#define ANC_STATUS_DISCONN    0x0400 /**< ANC_STATUS Bitmask: sensor disconn. */
#define ANC_STATUS_REF_VALID  0x0800 /**< ANC_STATUS Bitmask: reference valid.*/

/** Clear Overcurrent Error.
 *  The command clears the overcurrent error state to allow further operation.
 *  Data must be set to 1.
 */
#define ID_ANC_IMAX_RESET     0x3151
/* @} */


/** @name Position Information
 *
 *  @details The following position information addresses are read only,
 *  set functions will fail. They provide information about the current
 *  actuator positions and are sent periodically by the device if events
 *  are activated by @ref ID_ASYNC_EN.
 *  A few setable parameters control the behaviour of the position values.
 *  The index field transports the axis number.
 *  @{
 */

/** Position of the Axis.
 *  Unit is nm, or multiples of 100udeg for rotators or goniometers.
 */
#define ID_ANC_POSITION       0x0415

/** Position Synonym.
 *  This is an alternative name for the position address,
 *  provided for backward compatibility.
 */
#define ID_ANC_COUNTER        0x0415

/** Reference Position of the Axis.
 *  Position of the reference mark of the ANC350NUM sensor.
 *  Valid only if the mark has already been hit, see @ref ANC_STATUS_REF_VALID.
 *  Unit is nm, or multiples of 100udeg for rotators or goniometers.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_REF_POSITION   0x0407

/** Position Reset.
 *  Resets the (relative) position to zero without moving.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_POS_RESET      0x044F

/** Automatic Position Reset.
 *  Controls whether the position is reset automatically to zero whenever the
 *  sensors reference mark is hit.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_AUTO_RESET     0x3035

/** Automatic Reference Update.
 *  Controls whether the reference position is updated automatically whenever the
 *  sensors reference mark is hit, even if the position is already valid.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_REF_UPDATE     0x3034

/* @} */


/** @name Manual Positioning
 *
 *  @details The following addresses are used as "manual" positioning commands,
 *  i.e. the feedback loop is open. The index field transports the axis number.
 *  "1" in the data field starts the motion, "0" stops it. Also, every command
 *  stops all other commands (including automatic positioning).
 *
 *  The motion is carried out with the current settings for
 *  @ref ID_ANC_AMPL "amplitude" and @ref ID_ANC_FAST_FREQ "frequency".
 *  @{
 */

/** Step forward.
 *  Starts a one step move in forward direction.
 */
#define ID_ANC_SGL_FWD        0x0410

/** Step backward.
 *  Starts a one step move in backward direction.
 */
#define ID_ANC_SGL_BKWD       0x0411

/** Move forward continously.
 *  Starts or stops a continous move in forward direction.
 */
#define ID_ANC_CONT_FWD       0x040E

/** Move backward continously.
 *  Starts or stops a continous move in backward direction.
 */
#define ID_ANC_CONT_BKWD      0x040F

/** DC Level.
 *  Sets the DC level that the output voltage assumes
 *  after a motion has been completed.
 */
#define ID_ANC_ACT_AMPL       0x0514
/* @} */


/** @name Automatic Positioning
 *
 *  @details These addresses represent parameters, commands and states for
 *  automatic positioning, i.e. with closed feedback loop.
 *  The index field transports the axis number.
 *  The commands mean "start" with 1 in the data field and "stop" it with 0.
 *  Every command stops all other commands (including manual positioning).
 *
 *  The motion is carried out with the current
 *  @ref ID_ANC_FAST_FREQ "frequency". @ref ID_ANC_AMPL "amplitude"
 *  is used as maximum.
 *  @{
 */

/** Target Position.
 *  Sets the target position for automatic positioning.
    Unit is nm, or multiples of 100udeg for rotators or goniometers.
*/
#define ID_ANC_TARGET         0x0408

/** Target Range.
 *  Sets the range around the target position where the target will
 *  be considered as reached. Unit is nm, or multiples of 100udeg for rotators or goniometers.
*/
#define ID_ANC_TARGET_RANGE   0x3036

/** Absolute Move.
 *  Starts or stops an approach to the target position.
 */
#define ID_ANC_RUN_TARGET     0x040D

/** Absolute Move to Reference.
 *  Starts or stops an approach to the reference position.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_MOVE_REF       0x0444

/** Relative Move.
 *  Starts or stops an approach to a target relative to the
 *  current position.
 */
#define ID_ANC_RUN_RELATIVE   0x0418

/** Positioning State.
 *  This state variable reflects if the current target is considered
 *  as reached.
 */
#define ID_ANC_TARGET_STATUS  0x3037
/* @} */


/** @name Positioning Parameters
 *
 *  @details These parameters are relevant for all kinds of positioning.
 *  The index field transports the axis number.
 *  @{
 */

/** Output Enable.
 *  Enables or disables the signal output on an axis.
 */
#define ID_ANC_OUTPUT_EN      0x3030

/** Output Disable on EOT.
 *  If set to 1, the detection of a hump (EOT) causes the signal
 *  output to be disabled. To restart the motion, it has to be
 *  enabled again by @ref ID_ANC_OUTPUT_EN
 */
#define ID_ANC_STOP_EN        0x0450

/** Amplitude.
 *  Controls the output amplitude of the sawtooth signal; unit is mV.
 *  It is directly used in manual and as maximum in automatic positioning.
 */
#define ID_ANC_AMPL           0x0400

/** Frequency.
 *  Controls the output frequency of the sawtooth signal; unit is Hz.
 */
#define ID_ANC_FAST_FREQ      0x0401

/** Target Ground.
 *  If the set to 1, the DC level applied after the end of a motion
 *  is set to zero. Otherwise it depends on the kind of motion.
 */
#define ID_ANC_STOP_ZERO      0x0451
/* @} */


/** @name External Positioning Control
 *
 *  @details The positioning functions can be controlled by external
 *  interfaces of the device: trigger and quadrature input.
 *  These parameters enable and configure the external position control.
 *  All parameters belong to a specific axis, indicated by the index.
 *  @{
 */

/** Trigger Enable.
 *  If set to 1, a trigger signal on a trigger input line of the axis
 *  will cause a single step. The direction depends on the input line.
 */
#define ID_ANC_TRG_MODE       0x3042

/** Quadrature Input Enable.
 *  If set to 1, the quadrature input controls the target position of
 *  the automatic positioning function.
 */
#define ID_ANC_QUAD_IN_MODE   0x3044

/** Quadrature Input Resolution.
 *  The parameter specifies the step with represented by a state change
 *  of the quadrature input signal. Unit is nm, or multiples of 100udeg for rotators or goniometers.
 */
#define ID_ANC_QUAD_IN_PERIOD 0x3045
/* @} */


/** @name Quadrature Output
 *
 *  @details These parameters configure quadrature output interface,
 *  that can output the current position of an axis.
 *  All parameters belong to a specific axis, indicated by the index.
 *  @{
 */

/** Quadrature Output Enable.
 *  If set to 1, the current position is output on the quadrature
 *  output interface corresponding to the axis.
 */
#define ID_ANC_QUAD_OUT_MODE  0x3046

/** Quadrature Output Resolution.
 *  The parameter specifies the step with represented by a state change
 *  of the quadrature output signal. Unit is nm, or multiples of 100udeg for rotators or goniometers.
 */
#define ID_ANC_QUAD_OUT_PERIOD 0x3047

/** Quadrature Output Clock.
 *  Clock period of the quadrature output signal. Unit is 20ns,
 *  allowed range is 2 (40ns) ... 65535 (1,310700ms)
 */
#define ID_ANC_QUAD_OUT_CLOCK 0x3048
/* @} */


/** @name Capacitance Measurement
 *
 *  @details Allows to measure the capacitance of the piezo motor
 *  that is connected to an axis.
 *  @{
 */

/** Start the capacitance measurement.
 */
#define ID_ANC_CAP_START      0x051E

/** Result of the capacitance measurement.
 *  This address is read only and is sent by the controller
 *  automatically on finished measurement. Unit is pF.
 */
#define ID_ANC_CAP_VALUE      0x0569
/* @} */


/** @name Sensor Power Control
 *
 *  @details The following commands allow to control the sensor power loss
 *  and will thereby affect the sensor accuracy.
 *  @{
 */

/** Reference Voltage
 *  Allows to set the reference voltage for resistive sensors.
 *  Unit is mV. The voltage is set for all axes, only index 0 is valid.
 *  Only applicable to ANC350RES.
 */
#define ID_ANC_SENSOR_VOLT    0x0526

/** Sensor Power Enable
 *  Switches the sensor power on or off (0/1).
 *  Affects all axes, index must be 0.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_SENSOR_EN      0x058D

/** Duty Cycle Enable
 *  Switches the duty cycle feature on or off (0/1).
 *  Affects all axes, index must be 0.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_CYCLE_EN       0x0588

/** Duty Cycle Period
 *  Controls the duty cycle period. Unit is ms.
 *  Affects all axes, index must be 0.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_CYCLE_PERIOD   0x0589

/** Duty Cycle Off Time
 *  Controls the duty cycle off time. Unit is ms.
 *  Affects all axes, index must be 0.
 *  Only applicable to ANC350NUM.
 */
#define ID_ANC_CYCLE_OFFTIME  0x058A

/* @} */


/** @name Persistence Control of Parameters
 *
 *  @details Allows to save the most important parameters to persistent
 *  memory in the device or to clear the persistent memory.
 *  Only index 0 is valid.
 *  @{
 */

/** Save Command.
 *  A data value of "1234" saves all currently set parameters to
 *  persistent memory. A data value of "4321" clears all parameters.
 */
#define ID_ANC_ACTORPS_SAVE   0x050C
/* @} */


#endif
