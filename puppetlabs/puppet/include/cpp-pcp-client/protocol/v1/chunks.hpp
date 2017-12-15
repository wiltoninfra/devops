#pragma once

#include <cpp-pcp-client/protocol/v1/serialization.hpp>
#include <cpp-pcp-client/validator/schema.hpp>
#include <cpp-pcp-client/export.h>

#include <cpp-pcp-client/protocol/parsed_chunks.hpp>

#include <string>
#include <stdint.h>  // uint8_t

namespace PCPClient {
namespace v1 {

//
// ChunkDescriptor
//

namespace ChunkDescriptor {
    // Filter the chunk type bits (envelope, data, debug)
    static const uint8_t TYPE_MASK { 0x0F };

    static const uint8_t ENVELOPE { 0x01 };
    static const uint8_t DATA { 0x02 };
    static const uint8_t DEBUG { 0x03 };

    static std::map<uint8_t, const std::string> names {
        { ENVELOPE, "envelope" },
        { DATA, "data" },
        { DEBUG, "debug" }
    };

}  // namespace ChunkDescriptor

//
// MessageChunk
//

struct LIBCPP_PCP_CLIENT_EXPORT MessageChunk {
    uint8_t descriptor;
    uint32_t size;  // [byte]
    std::string content;

    MessageChunk();

    MessageChunk(uint8_t _descriptor, uint32_t _size, std::string _content);

    MessageChunk(uint8_t _descriptor, std::string _content);

    bool operator==(const MessageChunk& other_msg_chunk) const;

    void serializeOn(SerializedMessage& buffer) const;

    std::string toString() const;
};

using ParsedChunks = PCPClient::ParsedChunks;

}  // namespace v1
}  // namespace PCPClient
