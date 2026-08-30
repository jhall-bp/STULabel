// Copyright 2017–2018 Stephan Tolksdorf

#import "STUDefines.h"

#import <objc/runtime.h>

STU_EXTERN_C_BEGIN

/// A simple wrapper of @c class_createInstance callable from ARC code.
id _Nonnull stu_createClassInstance(Class _Nonnull cls, size_t extraBytes)
    OBJC_RETURNS_RETAINED;

/// A simple wrapper of @c objc_constructInstance callable from ARC code.
id _Nonnull stu_constructClassInstance(Class _Nonnull cls, void *_Nonnull storage)
    OBJC_RETURNS_RETAINED;

/// A simple wrapper of @c object_getIndexedIvars callable from ARC code.
void *_Nonnull stu_getObjectIndexedIvars(id _Nonnull object);

STU_EXTERN_C_END
