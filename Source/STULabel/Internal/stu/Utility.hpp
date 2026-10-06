// Copyright 2017–2018 Stephan Tolksdorf

#pragma once

#include "stu/Casts.hpp"
#include "stu/Parameter.hpp"

#include <bit>
#include <functional>
#include <new>

namespace stu {

struct Fixed { explicit Fixed() = default; };

struct NotSpecialized { explicit NotSpecialized() = default; };
constexpr struct Unchecked { explicit Unchecked() = default; } unchecked;
constexpr struct Uninitialized { explicit Uninitialized() = default; } uninitialized;
constexpr struct ZeroInitialized { explicit ZeroInitialized() = default; } zeroInitialized;
constexpr struct InPlace { explicit InPlace() = default; } inPlace;

template <typename Int>
struct Count : Parameter<Count<Int>, Int> {
  using Base = Parameter<Count<Int>, Int>;
  using Base::Base;
  using Base::operator=;

  template <typename T>
    requires (isSafelyConvertible<T, Int>)
  /* implicit */ STU_CONSTEXPR_T
  Count(Count<T> other) : Base{other.value} {}

  template <typename T>
    requires (isSafelyConvertible<T, Int>)
  /* implicit */ STU_CONSTEXPR_T
  Count& operator=(const Count<T> other) { return *this = other.value; }
};
template <typename Int> Count(Int value) -> Count<Int>;

template <typename Int>
struct Capacity : Parameter<Capacity<Int>, Int> {
  using Base = Parameter<Capacity<Int>, Int>;
  using Base::Base;
  using Base::operator=;

  template <typename T>
    requires (isSafelyConvertible<T, Int>)
  /* implicit */ STU_CONSTEXPR_T
  Capacity(Capacity<T> other) : Base{other.value} {}

  template <typename T>
    requires (isSafelyConvertible<T, Int>)
  /* implicit */ STU_CONSTEXPR_T
  Capacity& operator=(const Capacity<T> other) { return *this = other.value; }
};
template <typename Int> Capacity(Int value) -> Capacity<Int>;

template <typename... Ts>
STU_CONSTEXPR_T
void discard(const Ts&...) {}

template <typename T, int N>
STU_CONSTEXPR_T int arrayLength(const T (&)[N]) { return N; }

#define STU_ARRAY_LENGTH(array) std::extent_v<decltype(array)>

template <typename UInt>
STU_CONSTEXPR
int countLeadingZeroBits(UInt value) {
  static_assert(isUnsigned<UInt>);
  return std::countl_zero(static_cast<UInt_<sizeof(UInt)*8>>(value));
}

/// Tests whether the integer argument is a positive power of two.
template <typename Int>
STU_CONSTEXPR bool isPowerOfTwo(Int value) {
  return value > 0 && (value & (value - 1)) == 0;
}

template <auto d, typename Int>
  requires (isPowerOfTwo(d))
STU_CONSTEXPR Int roundDownToMultipleOf(Int value) {
  return static_cast<Int>(value & ~static_cast<Int>(d - 1));
}

/// Doesn't check for overflow.
template <auto d, typename Int>
  requires (isPowerOfTwo(d))
STU_CONSTEXPR Int roundUpToMultipleOf(Int value) {
  return static_cast<Int>((value + (d - 1)) & ~static_cast<Int>(d - 1));
}

template <typename UInt>
STU_CONSTEXPR
UInt roundUpToPowerOfTwo(UInt value) {
  static_assert(isUnsigned<UInt>);
  return STU_LIKELY(2 <= value && value <= IntegerTraits<UInt>::max/2 + 1)
       ? static_cast<UInt>(std::bit_ceil(static_cast<UInt_<sizeof(UInt)*8>>(value)))
       : value;
}

template <int alignment>
STU_CONSTEXPR bool isAligned(const void* pointer) {
  static_assert(isPowerOfTwo(alignment));
  return (reinterpret_cast<uintptr_t>(pointer) & (alignment - 1)) == 0;
}

template <typename T>
STU_CONSTEXPR bool isAligned(const void* pointer) {
  return isAligned<alignof(T)>(pointer);
}


template <typename T1, typename T2>
using Pair = std::pair<T1, T2>;

template <typename T1, typename T2>
STU_CONSTEXPR_T auto pair(T1&& a, T2&& b) {
  return Pair<Decay<T1>, Decay<T2>>{std::forward<T1>(a), std::forward<T2>(b)};
}

template <typename T1, typename T2>
struct IsBitwiseCopyable<Pair<T1, T2>>
       : BoolConstant<IsBitwiseCopyable<T1>::value && IsBitwiseCopyable<T2>::value>
{};

template <typename T1, typename T2>
struct IsBitwiseMovable<Pair<T1, T2>>
       : BoolConstant<IsBitwiseMovable<T1>::value && IsBitwiseMovable<T2>::value>
{};

} // namespace stu
