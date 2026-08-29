// Copyright 2018 Stephan Tolksdorf

@import STULabel.Mutex;

@import XCTest;

@interface MutexTests : XCTestCase

@end

@implementation MutexTests

- (void)testInitializer
{
  stu_mutex mutex = STU_MUTEX_INIT;
  stu_mutex mutex2;
  stu_mutex_init(&mutex2);
  XCTAssertTrue(memcmp(&mutex, &mutex2, sizeof(mutex)) == 0);
  os_unfair_lock unfair_lock = OS_UNFAIR_LOCK_INIT;
  XCTAssertTrue(memcmp(&mutex.unfair_lock, &unfair_lock, sizeof(unfair_lock)) == 0);
}

- (void)testLocking
{
  stu_mutex mutex = STU_MUTEX_INIT;
  XCTAssertTrue(stu_mutex_trylock(&mutex));
  XCTAssertTrue(!stu_mutex_trylock(&mutex));
  stu_mutex_unlock(&mutex);
  XCTAssertTrue(stu_mutex_trylock(&mutex));
  XCTAssertTrue(!stu_mutex_trylock(&mutex));
  stu_mutex_unlock(&mutex);
  stu_mutex_lock(&mutex);
  stu_mutex_unlock(&mutex);
  XCTAssertTrue(stu_mutex_trylock(&mutex));
  XCTAssertTrue(!stu_mutex_trylock(&mutex));
  stu_mutex_destroy(&mutex);
  mutex = STU_MUTEX_INIT;
  XCTAssertTrue(stu_mutex_trylock(&mutex));
  XCTAssertTrue(!stu_mutex_trylock(&mutex));
  stu_mutex_unlock(&mutex);
  stu_mutex_destroy(&mutex);
}

@end
