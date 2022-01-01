/*
** $Id: lmem.c,v 1.70.1.1 2007/12/27 13:02:25 roberto Exp $
** Interface to Memory Manager
** See Copyright Notice in lua.h
*/


#include <stddef.h>

#define lmem_c
#define LUA_CORE

#include "lua.h"

#include "ldebug.h"
#include "ldo.h"
#include "lmem.h"
#include "lobject.h"
#include "lstate.h"



/*
** About the realloc function:
** void * frealloc (void *ud, void *ptr, size_t osize, size_t nsize);
** (`osize' is the old size, `nsize' is the new size)
**
** Lua ensures that (ptr == NULL) iff (osize == 0).
**
** * frealloc(ud, NULL, 0, x) creates a new block of size `x'
**
** * frealloc(ud, p, x, 0) frees the block `p'
** (in this specific case, frealloc must return NULL).
** particularly, frealloc(ud, NULL, 0, 0) does nothing
** (which is equivalent to free(NULL) in ANSI C)
**
** frealloc returns NULL if it cannot create or reallocate the area
** (any reallocation to an equal or smaller size cannot fail!)
*/



#define MINSIZEARRAY	4


void *luaM_growaux_ (lua_State *L, void *block, int *size, size_t size_elems,
                     int limit, const char *errormsg) {
  void *newblock;
  int newsize;
  if (*size >= limit/2) {  /* cannot double it? */
    if (*size >= limit)  /* cannot grow even a little? */
      luaG_runerror(L, errormsg);
    newsize = limit;  /* still have at least one free place */
  }
  else {
    newsize = (*size)*2;
    if (newsize < MINSIZEARRAY)
      newsize = MINSIZEARRAY;  /* minimum size */
  }
  newblock = luaM_reallocv(L, block, *size, newsize, size_elems);
  *size = newsize;  /* update only when everything else is OK */
  return newblock;
}


void *luaM_toobig (lua_State *L) {
  luaG_runerror(L, "memory allocation error: block too big");
  return NULL;  /* to avoid warnings */
}



/*
** generic allocation routine.
*/
// Seemingly, allocations are innocuous by themselves; only the allocations within
//  table values seem to go awry by the end, corrupting the heap on final gc. It's
//  probably a minor structure difference between the implementations. The gc
//  implementations might also differ, but allocations work.
#if 0
#include <stdio.h>
static void *l_alloc (void *ud, void *ptr, size_t osize,
                                           size_t nsize) {
  (void)ud;  (void)osize;  /* not used */
  if (nsize == 0) {
    fprintf(stderr, "luaM_realloc_ l_alloc free called: %x %d %d ... leaking to avoid double-free.\n", ptr, osize, nsize);
    //free(ptr);
    return NULL;
  }
  else
    return realloc(ptr, nsize);
}
void *luaM_realloc_ (lua_State *L, void *block, size_t osize, size_t nsize) {
  global_State *g = G(L);
  void* oblock = block;



  lua_assert((osize == 0) == (block == NULL));

  //block = (*g->frealloc)(g->ud, block, osize, nsize);
  block = l_alloc(g->ud, block, osize, nsize);

  if (block == NULL && nsize > 0) {
    fprintf(stderr, "luaM_realloc_ failed allocation: %x %d %d -> %x\n", oblock, osize, nsize, block);
    luaD_throw(L, LUA_ERRMEM);
  }
  lua_assert((nsize == 0) == (block == NULL));
  g->totalbytes = (g->totalbytes - osize) + nsize;

  // Log this out because it's a bug for realloc to be called from this library.
  // Things might work for a while, but in general the host app (Renoise) needs to fully manage memory.
  fprintf(stderr, "WARNING: luaM_realloc_ called: %x %d %d -> %x\n", oblock, osize, nsize, block);

  return block;
}
#elif 0
#include <stdio.h>
void *luaM_realloc_ (lua_State *L, void *block, size_t osize, size_t nsize) {
  global_State *g = G(L);
  void* oblock = block;

  lua_assert((osize == 0) == (block == NULL));
  block = (*g->frealloc)(g->ud, block, osize, nsize);
  if (block == NULL && nsize > 0) {
    fprintf(stderr, "luaM_realloc_ failed allocation: %x %d %d -> %x\n", oblock, osize, nsize, block);
    luaD_throw(L, LUA_ERRMEM);
  }
  lua_assert((nsize == 0) == (block == NULL));
  g->totalbytes = (g->totalbytes - osize) + nsize;

  // Log this out because it's a bug for realloc to be called from this library.
  // Things might work for a while, but in general the host app (Renoise) needs to fully manage memory.
  fprintf(stderr, "ERROR: luaM_realloc_ called: %x %d %d -> %x\n", oblock, osize, nsize, block);

  return block;
}
#else
void *luaM_realloc_ (lua_State *L, void *block, size_t osize, size_t nsize) {
  global_State *g = G(L);
  lua_assert((osize == 0) == (block == NULL));
  block = (*g->frealloc)(g->ud, block, osize, nsize);
  if (block == NULL && nsize > 0)
    luaD_throw(L, LUA_ERRMEM);
  lua_assert((nsize == 0) == (block == NULL));
  g->totalbytes = (g->totalbytes - osize) + nsize;
  return block;
}
#endif
