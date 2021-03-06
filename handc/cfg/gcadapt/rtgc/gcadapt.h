/*-----------------------------------------------------------------*-C-*---
 * File:    handc/cfg/gcadapt/rtgc/gcadapt.h
 *
 *          Copyright (C)1997 Donovan Kolbly <d.kolbly@rscheme.org>
 *          as part of the RScheme project, licensed for free use.
 *          See <http://www.rscheme.org/> for the latest information.
 *
 * File version:     1.5
 * File mod date:    1997-11-29 23:10:45
 * System build:     v0.7.3.4-b7u, 2007-05-30
 *
 *------------------------------------------------------------------------*/

/* interface to the garbage collector */

#include <rscheme/gcserver.h>

int gc_for_each( int (*fn)( void *info, void *heap_obj ), void *info );
