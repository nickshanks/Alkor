#include <stdint.h>
#import <CoreFoundation/CFBase.h>

CF_EXTERN_C_BEGIN

uint32_t read_bits(const uint8_t *data, uint32_t *bit_offset, const uint32_t size);
void set_bits(uint8_t *data, const uint32_t value, uint32_t *bit_offset, const uint32_t size);

CF_EXTERN_C_END
