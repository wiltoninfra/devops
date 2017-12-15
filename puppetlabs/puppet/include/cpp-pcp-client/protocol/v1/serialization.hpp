#pragma once

#include <cpp-pcp-client/export.h>
#include <cpp-pcp-client/protocol/v1/errors.hpp>

#include <leatherman/locale/locale.hpp>

#include <boost/detail/endian.hpp>

#include <string>
#include <vector>
#include <stdint.h>  // uint8_t
#include <utility>
#include <stdexcept>

// TODO(ale): disable assert() once we're confident with the code...
// To disable assert()
// #define NDEBUG
#include <cassert>

namespace PCPClient {
namespace v1 {

typedef std::vector<uint8_t> SerializedMessage;

//
// Utility functions
//

#ifdef BOOST_LITTLE_ENDIAN

LIBCPP_PCP_CLIENT_EXPORT uint32_t getNetworkNumber(const uint32_t& number);
LIBCPP_PCP_CLIENT_EXPORT uint32_t getHostNumber(const uint32_t& number);

#else  // we're using big endian (!)

inline uint32_t getNetworkNumber(const uint32_t& number) {
    return number;
}

inline uint32_t getHostNumber(const uint32_t& number) {
    return number;
}

#endif  // BOOST_LITTLE_ENDIAN

//
// Serialize
//

// Internal template function and specializations

template<typename T>
inline void serialize_(const T& thing,
                       SerializedMessage::iterator& buffer_itr);

template<>
inline void serialize_(const std::string& txt,
                       SerializedMessage::iterator& buffer_itr) {
    for (const auto& c : txt) {
        auto ptr = reinterpret_cast<const uint8_t*>(&c);
        std::copy(ptr, ptr + sizeof(c), buffer_itr);
        buffer_itr += sizeof(c);
    }
}

template<>
inline void serialize_(const uint32_t& number,
                       SerializedMessage::iterator& buffer_itr) {
    auto network_number = getNetworkNumber(number);
    auto byte_ptr = reinterpret_cast<const uint8_t*>(&network_number);
    std::copy(byte_ptr, byte_ptr + 4, buffer_itr);
    buffer_itr += 4;
}


template<>
inline void serialize_(const uint8_t& number,
                       SerializedMessage::iterator& buffer_itr) {
    auto byte_ptr = reinterpret_cast<const uint8_t*>(&number);
    std::copy(byte_ptr, byte_ptr + 1, buffer_itr);
    buffer_itr += 1;
}

// Serialize the specified type T object, of given size. The encoded
// bytes will be stored in the passed buffer, which will be resized.
// Throw a message_serialization_error in case it fails to resize the
// buffer.
template<typename T>
inline void serialize(const T& thing,
                      size_t thing_size,
                      SerializedMessage& buffer) {
    auto offset = buffer.size();

    try {
        buffer.resize(offset + thing_size);
    } catch (std::bad_alloc) {
        throw message_serialization_error {
            leatherman::locale::translate("serialization: bad allocation") };
    } catch (const std::exception& e) {
        throw message_serialization_error { e.what() };
    } catch (...) {
        throw message_serialization_error {
            leatherman::locale::translate("serialization: unexpected error when "
                                          "allocating memory") };
    }

    SerializedMessage::iterator buffer_itr = buffer.begin() + offset;
    serialize_<T>(thing, buffer_itr);
    assert(buffer_itr == buffer.begin() + offset + thing_size);
}

//
// Deserialize
//

// Deserialize the type T thing of given size (byte); this thing is
// assumed stored in consecutive memory - the specified iterator
// should point to its starting byte. Return the deserialized value of
// the thing and increment the iterator, that will point to what comes
// right after the deserialized thing.
// Note that it's up to the caller to guarantee that the thing is
// actually stored in consecutive memory.
template<typename T>
inline T deserialize(size_t thing_size,
                     SerializedMessage::const_iterator& start);

// Specializations

template<>
inline std::string deserialize(size_t thing_size,
                               SerializedMessage::const_iterator& start) {
    auto value = std::string(start, start + thing_size);
    start += thing_size;
    return value;
}

template<>
inline uint8_t deserialize(size_t thing_size,
                           SerializedMessage::const_iterator& start) {
    assert(thing_size == 1);
    uint8_t value;
    uint8_t* byte_ptr = reinterpret_cast<uint8_t*>(&value);
    std::copy(start, start + thing_size, byte_ptr);
    start += thing_size;
    return value;
}

template<>
inline uint32_t deserialize(size_t thing_size,
                            SerializedMessage::const_iterator& start) {
    assert(thing_size == 4);
    uint32_t value;
    uint8_t* byte_ptr = reinterpret_cast<uint8_t*>(&value);
    std::copy(start, start + thing_size, byte_ptr);
    start += thing_size;
    return getHostNumber(value);
}

}  // namespace v1
}  // namespace PCPClient
