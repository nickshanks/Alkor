#include "bits.h"
#import <CoreFoundation/CFByteOrder.h>

uint32_t read_bits(const uint8_t *data, uint32_t *bit_offset, const uint32_t size)
{
	if (size > 24)
	{
		uint32_t temp_result = read_bits(data, bit_offset, 16);
		return temp_result | (read_bits(data, bit_offset, size-16) << 16);
	}
	else
	{
		uint32_t result = (CFSwapInt32LittleToHost(*(uint32_t *) &data[(*bit_offset)/8]) >> ((*bit_offset) & 7)) & ((1 << size) - 1);
		*bit_offset += size;
		return result;
	}
}

void set_bits(uint8_t *data, const uint32_t value, uint32_t *bit_offset, const uint32_t size)
{
	if (size > 24)
	{
		set_bits(data, (value & 0x0000FFFF), bit_offset, 16);
		set_bits(data, (value >> 16), bit_offset, size-16);
	}
	else
	{																					// ABCDEFGH IJKLMNOP QRSTUVWX YZabcdef
		uint32_t temp = CFSwapInt32LittleToHost(*(uint32_t *) &data[(*bit_offset)/8]);	// YZabcdef QRSTUVWX IJKLMNOP ABCDEFGH
		uint32_t mask = (1 << size) - 1;												// 00000000 00000000 00000111 11111111
		mask <<= ((*bit_offset) % 8);													// 00000000 00000000 00111111 11111000
		mask = ~mask;																	// 11111111 11111111 11000000 00000111
		temp &= mask;																	// YZabcdef QRSTUVWX IJ000000 00000FGH
		temp |= (value << ((*bit_offset) % 8));											// YZabcdef QRSTUVWX IJXXXXXX XXXXXFGH
		*(uint32_t *) &data[(*bit_offset)/8] = CFSwapInt32LittleToHost(temp);			// XXXXXFGH IJXXXXXX QRSTUVWX YZabcdef
		*bit_offset += size;
	}
}
