// Copyright 2016–2018 Stephan Tolksdorf

#pragma once

#include "STUDefines.h"

#include <os/lock.h>

STU_EXTERN_C_BEGIN

/// A mutex backed by os_unfair_lock.
///
/// Must be initialized with @c STU_MUTEX_INIT or @c stu_mutex_init and destroyed with
/// @c stu_mutex_destroy.
///
/// @warning
///  This type has to be handled like @c os_unfair_lock. If you're not familiar with that type and
///  know how to use it, then you shouldn't use @c stu_mutex.
typedef struct stu_mutex {
  os_unfair_lock unfair_lock;
} stu_mutex;

#define STU_MUTEX_INIT                                                                                                 \
  (stu_mutex) {                                                                                                        \
    .unfair_lock = OS_UNFAIR_LOCK_INIT                                                                                 \
  }

static STU_INLINE void stu_mutex_destroy(stu_mutex *__nonnull) { /* do nothing */
}

static STU_INLINE bool stu_mutex_trylock(stu_mutex *__nonnull mutex) {
  return os_unfair_lock_trylock(&mutex->unfair_lock);
}

static STU_INLINE void stu_mutex_lock(stu_mutex *__nonnull mutex) {
  os_unfair_lock_lock(&mutex->unfair_lock);
}

static STU_INLINE void stu_mutex_unlock(stu_mutex *__nonnull mutex) {
  os_unfair_lock_unlock(&mutex->unfair_lock);
}

/// Initializes the mutex. Equivalent to `*mutex = STU_MUTEX_INIT`.
static STU_INLINE void stu_mutex_init(stu_mutex *__nonnull mutex) {
  *mutex = STU_MUTEX_INIT;
}

STU_EXTERN_C_END
