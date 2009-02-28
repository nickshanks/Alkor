#include <Foundation/Foundation.h>

NSMutableArray *read_property_list(const uint8_t *data, uint32_t *bit_offset, bool csave = false);
void write_property_list(uint8_t *buffer, uint32_t *bit_offset, NSArray *plist, bool csave = false);
