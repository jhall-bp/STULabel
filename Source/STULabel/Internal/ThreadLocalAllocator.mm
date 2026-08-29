// Copyright 2017–2018 Stephan Tolksdorf

#import "ThreadLocalAllocator.hpp"

namespace stu_label {

thread_local ThreadLocalArenaAllocator *ThreadLocalArenaAllocator::instance_pointer;

} // namespace stu_label
