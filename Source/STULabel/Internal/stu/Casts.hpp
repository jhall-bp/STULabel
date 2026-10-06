// Copyright 2017 Stephan Tolksdorf

#pragma once

#include "stu/TypeTraits.hpp"

#include <bit>

namespace stu {

using std::bit_cast;

template <typename T>
STU_CONSTEXPR_T
T implicit_cast(std::type_identity_t<T> value) noexcept {
  return static_cast<T>(value); // The static_cast is necesary for rvalue references.
}


template <typename Int>
  requires (isInteger<Int>)
STU_CONSTEXPR_T
auto sign_cast(Int value) noexcept {
  using Result = Conditional<isSigned<Int>, Unsigned<Int>, Signed<Int>>;
  return static_cast<Result>(value);
}

template <typename T, typename U>
STU_CONSTEXPR_T
T narrow_cast(U&& value) noexcept(noexcept(static_cast<T>(value))) {
  return static_cast<T>(value);
}

template <typename T, typename U>
  requires (isPointer<T> && isConvertible<T, const U*>)
STU_CONSTEXPR_T
T down_cast(U* value) noexcept {
  return static_cast<T>(value);
}

template <typename T, typename U>
  requires (isReference<T> && isConvertible<T, const U&>)
STU_CONSTEXPR_T
T down_cast(U& value) noexcept {
  return static_cast<T>(value);
}

} // namespace stu
