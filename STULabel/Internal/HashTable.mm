// Copyright 2017–2018 Stephan Tolksdorf

#import "HashTable.hpp"

namespace stu_label {

template class HashTable<UInt16, NoType, Malloc>;
template class HashTable<UInt16, NoType, ThreadLocalAllocatorRef>;

} // namespace stu_label
