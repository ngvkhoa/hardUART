// Bảng mã LED 7 đoạn Cathode chung (0 -> F)
// Bit: 0b0 [G][F][E][D][C][B][A]
const uint8_t lut_cc[16] = {
  0b00111111, // 0
  0b00000110, // 1
  0b01011011, // 2
  0b01001111, // 3
  0b01100110, // 4
  0b01101101, // 5
  0b01111101, // 6
  0b00000111, // 7
  0b01111111, // 8
  0b01101111, // 9
  0b01110111, // A
  0b01111100, // b
  0b00111001, // C
  0b01011110, // d
  0b01111001, // E
  0b01110001  // F
};

void setup() {
  // Cấu hình A0, A1, A2, A3 (PC0..PC3) làm INPUT
  DDRC &= ~0b00001111;
  
  // Cấu hình D2..D7 (PD2..PD7) làm OUTPUT, giữ nguyên D0/D1
  DDRD |= 0b11111100;
  
  // Cấu hình D8 (PB0) làm OUTPUT
  DDRB |= 0b00000001;
}

void loop() {
  // Đọc trực tiếp 4-bit Nibble từ chân A0..A3 (KHÔNG dịch >> 1 nữa)
  uint8_t addr = PINC & 0x0F;

  // Lấy mã hiển thị từ Look-Up Table
  uint8_t seg = lut_cc[addr];

  // Xuất ra D2..D7 (thanh a..f) và D8 (thanh g)
  PORTD = (PORTD & 0x03) | ((seg & 0x3F) << 2);
  if (seg & 0x40) {
    PORTB |= 0x01;
  } else {
    PORTB &= ~0x01;
  }
}