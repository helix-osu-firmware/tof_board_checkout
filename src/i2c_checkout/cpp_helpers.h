#ifndef CPP_HELPERS_H
#define CPP_HELPERS_H

// massive abuse!!

#define CAT(x, ...) PRIMITIVE_CAT(x, __VA_ARGS__)
#define PRIMITIVE_CAT(x, y) x ## y

#define IF_1(true, ...) true
#define IF_0(true, ...) __VA_ARGS__
#define IF(value) PRIMITIVE_CAT(IF_, value)

#define EAT(...)
#define EXPAND_TEST_EXISTS(...) EXPANDED, EXISTS( __VA_ARGS__ ) ) EAT (
#define GET_TEST_EXISTS_RESULT(x) ( CAT(EXPAND_TEST_, x), DOESNT_EXIST )

#define GET_TEST_EXIST_VALUE_(expansion, existValue) existValue
#define GET_TEST_EXIST_VALUE(x) GET_TEST_EXIST_VALUE_ x
#define TEST_EXISTS(x) GET_TEST_EXIST_VALUE ( GET_TEST_EXISTS_RESULT(x) )

#define DOES_VALUE_EXIST_EXISTS(...) 1
#define DOES_VALUE_EXIST_DOESNT_EXIST 0
#define DOES_VALUE_EXIST(x) CAT(DOES_VALUE_EXIST_, x)
#define TRY_EXTRACT_EXISTS(value, ...) \
  IF ( DOES_VALUE_EXIST(TEST_EXISTS(value)) )\
    ( EXTRACT_VALUE(value), __VA_ARGS__ )

#endif
