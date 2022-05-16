#*******************************************************************************
#  Project:        ANC350V3 Control Library
#
#  Filename:       makefile
#
#  Purpose:        MSVC makefile for trivial example
#
#  Author:         N-Hands GmbH & Co KG
#*******************************************************************************
# $Id: makefile.win,v 1.3 2015/12/15 17:14:47 trurl Exp $

all : anc350v4.dll example0.exe

example0.exe : example0.c ..\lib\anc350v4.lib
	cl -nologo -Zi -W3 -MD -I..\inc ..\lib\anc350v4.lib example0.c

anc350v4.dll : ..\lib\anc350v4.dll
	copy ..\lib\anc350v4.dll .

