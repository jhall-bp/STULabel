// Copyright 2017–2018 Stephan Tolksdorf

#include "STUObjCRuntimeWrappers.h"

#include "stu/Assert.h"

STU_EXPORT STU_NO_INLINE id stu_createClassInstance(Class cls, size_t extraBytes)
{
  void *const instance = class_createInstance(cls, extraBytes);
  STU_CHECK_MSG(instance != nil, "Failed to allocate class instance.");
  return instance;
}

STU_EXPORT STU_NO_INLINE id stu_constructClassInstance(Class cls, void *storage)
{
  const id instance = objc_constructInstance(cls, storage);
  STU_CHECK_MSG(instance != nil, "Failed to construct class instance.");
  return instance;
}

STU_EXPORT
void *stu_getObjectIndexedIvars(id object) { return object_getIndexedIvars(object); }
