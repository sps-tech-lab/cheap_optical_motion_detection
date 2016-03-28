/////////////////////////////////////////////////////////////////////////////////////////////
//  SPS Technology :: 2016  ////////////////////////////  Smart Motion Sensor OV7670 tests //
/////////////////////////////////////////////////////////////////////////////////////////////

// Дефайны TWI

#define TW_START   0x08
#define TW_REP_START   0x10
#define TW_MT_SLA_ACK   0x18
#define TW_MT_SLA_NACK   0x20
#define TW_MT_DATA_ACK   0x28
#define TW_MT_DATA_NACK   0x30
#define TW_MT_ARB_LOST   0x38
#define TW_MR_ARB_LOST   0x38
#define TW_MR_SLA_ACK   0x40
#define TW_MR_SLA_NACK   0x48
#define TW_MR_DATA_ACK   0x50
#define TW_MR_DATA_NACK   0x58
#define TW_ST_SLA_ACK   0xA8
#define TW_ST_ARB_LOST_SLA_ACK   0xB0
#define TW_ST_DATA_ACK   0xB8
#define TW_ST_DATA_NACK   0xC0
#define TW_ST_LAST_DATA   0xC8
#define TW_SR_SLA_ACK   0x60
#define TW_SR_ARB_LOST_SLA_ACK   0x68
#define TW_SR_GCALL_ACK   0x70
#define TW_SR_ARB_LOST_GCALL_ACK   0x78
#define TW_SR_DATA_ACK   0x80
#define TW_SR_DATA_NACK   0x88
#define TW_SR_GCALL_DATA_ACK   0x90
#define TW_SR_GCALL_DATA_NACK   0x98
#define TW_SR_STOP   0xA0
#define TW_NO_INFO   0xF8
#define TW_BUS_ERROR   0x00
#define TW_STATUS_MASK
#define TW_STATUS   (TWSR & TW_STATUS_MASK)

// Дефайны OV7670

#define camAddr_WR  0x42
#define camAddr_RD  0x43
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  Serial.begin(56000);  // Настраиваем последовательный порт
  HrdwareInit();        // Настраиваем периферию
  camInit();
                                                                
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void loop() {
  Serial.write(255);
  Serial.write(DDRB);
  Serial.write(ASSR);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void HrdwareInit(void) {
  
    // Настраиваем генератор тактового сигнала на 8МГц
  DDRB = 0x00;                                                                 // Чистим порт от предустановок. Актуально для Arduino Nano v3
  DDRB |= _BV(PB3);                                                            // Для генерации сигнала XCLK используем пин PB3 (#11 Arduino Nano v3)
  ASSR &= ~(1 << EXCLK | 1 << AS2);                                            // Частота с внешнего кварца / асинхронный таймер
  TCCR2A = (1 << COM2A0) | (1 << WGM21) | (1 << WGM20);                        // выход в [1] при совпадении / режим Fast PWM / режим Fast PWM
  TCCR2B = (1 << WGM22) | (1 << CS20);                                         // режим Fast PWM / без предделителя
  OCR2A = 0;                                                                   // [F_CPU/2]
  DDRC &= ~(1 << PC0 | 1 << PC1 | 1 << PC2 | 1 << PC3);                        // Входы для парралельного порта камеры (Arduino D0-D3)
  DDRD &= ~(1 << PD2 | 1 << PD3 | 1 << PD4 | 1 << PD5 | 1 << PD6 | 1 << PD7);  // Входы для парралельного порта камеры и входы синхронизации (Arduino D4-D7)
  _delay_ms(3000);

  // Настройка TWI
  TWSR &= ~(1 << TWPS0 | 1 << TWPS1);                                          //Отключаем предделитель для TWI (Предделитель = 1)
  TWBR = 72;                                                                   //Настройка TWI на 100кГц [F_CPU/(16+2*TWBR*Prescaler)]
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void camInit(void){
  wrReg(0x12, 0x80);
  _delay_ms(100);
//  wrSensorRegs8_8(ov7670_default_regs);
//  wrReg(REG_COM10, 32);//PCLK does not toggle on HBLANK.
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////// ФУНКЦИИ РАБОТЫ С I2C //////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------[ Начало передачи ]
void twiStart(void){
  TWCR = _BV(TWINT) | _BV(TWSTA) | _BV(TWEN);          //send start
  while (!(TWCR & (1 << TWINT)));                      //wait for start to be transmitted
  if ((TWSR & 0xF8) != TW_START)
    error();
}
//-----------------------------------------------------------[ Передать байт ]
void twiWriteByte(uint8_t DATA, uint8_t type){
  TWDR = DATA;
  TWCR = _BV(TWINT) | _BV(TWEN);
  while (!(TWCR & (1 << TWINT))) {}
  if ((TWSR & 0xF8) != type)
    error();;
}
//-----------------------------------------------------------[ Передать адрес ]
void twiAddr(uint8_t addr, uint8_t typeTWI){
  TWDR = addr;                                          // send address
  TWCR = _BV(TWINT) | _BV(TWEN);                        // clear interrupt to start transmission 
  while ((TWCR & _BV(TWINT)) == 0);                     // wait for transmission */
  if ((TWSR & 0xF8) != typeTWI)
    error();
}
//-----------------------------------------------------------[ Передать регистр ]
void wrReg(uint8_t reg, uint8_t dat){
  //send start condition
  twiStart();
  twiAddr(camAddr_WR, TW_MT_SLA_ACK);
  twiWriteByte(reg, TW_MT_DATA_ACK);
  twiWriteByte(dat, TW_MT_DATA_ACK);
  TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWSTO);     //send stop
  _delay_ms(1);
}
//-----------------------------------------------------------[ Принять байт ]
static uint8_t twiRd(uint8_t nack){
  if (nack){
    TWCR = _BV(TWINT) | _BV(TWEN);
    while ((TWCR & _BV(TWINT)) == 0);                   // wait for transmission
    if ((TWSR & 0xF8) != TW_MR_DATA_NACK)
      error();
    return TWDR;
  }
  else{
    TWCR = _BV(TWINT) | _BV(TWEN) | _BV(TWEA);
    while ((TWCR & _BV(TWINT)) == 0);                   // wait for transmission
    if ((TWSR & 0xF8) != TW_MR_DATA_ACK)
      error();
    return TWDR;
  }
}
//-----------------------------------------------------------[ Принять регистр ]
uint8_t rdReg(uint8_t reg){
  uint8_t dat;
  twiStart();
  twiAddr(camAddr_WR, TW_MT_SLA_ACK);
  twiWriteByte(reg, TW_MT_DATA_ACK);
  TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWSTO);     //send stop
  _delay_ms(1);
  twiStart();
  twiAddr(camAddr_RD, TW_MR_SLA_ACK);
  dat = twiRd(1);
  TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWSTO);     //send stop
  _delay_ms(1);
  return dat;
}
//-----------------------------------------------------------[ Ошибка ]
void error(void){
  ///
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

