#*******************************************************************************
#  Project:        ANC350V3 Control Library
#
#  Filename:       makefile
#
#  Purpose:        MSVC makefile for trivial example
#
#  Author:         N-Hands GmbH & Co KG
#*******************************************************************************
# $Id: makefile.win,v 1.2 2015/10/16 09:11:19 trurl Exp $

all : anc350v3.dll example0.exe

example0.exe : example0.c ..\lib\anc350v3.lib
	cl -nologo -Zi -W3 -MD -I..\inc ..\lib\anc350v3.lib example0.c

anc350v3.dll : ..\lib\anc350v3.dll
	copy ..\lib\anc350v3.dll .

