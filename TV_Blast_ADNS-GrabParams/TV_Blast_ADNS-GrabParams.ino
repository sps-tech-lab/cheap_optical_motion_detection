/////////////////////////////////////////////////////////////////////////////////////////////
//  SPS Technology :: 2016  //////////////////////////////  ADNS-5030 Smart Motion Sensor  //
/////////////////////////////////////////////////////////////////////////////////////////////

#define NCS   2     // Статус связи
#define SCLK  3     // Тактовый сигнал линии передачи
#define MOSI  4     // Отправка данных
#define MISO  5     // Прием данных

// ADNS-5030 REGISTERs

#define ADNS_MOTION             0x02      // Было ли движение
#define ADNS_DELTA_X            0x03      // Дельта перемещения по X
#define ADNS_DELTA_Y            0x04      // Дельта перемещения по Y
#define ADNS_SQUAL              0x05      // Качество поверхности
#define ADNS_SHUTTER_UPPER      0x06      // Старший бит "затвора" (О_о)
#define ADNS_SHUTTER_LOWER      0x07      // Младший бит "затвора" (О_о)
#define ADNS_MAX_PIX            0x08      // Максимальное кол-во пикседей в кадре
#define ADNS_PIX_SUM            0x09      // Сумма пикселей в последнем кадре
#define ADNS_MIN_PIX            0x0A      // Минимальное кол-во пикседей в кадре
#define ADNS_PIX_GRAB           0x0B      // Считывание пикселей напрямую с ПЗС-матрицы
#define ADNS_MOUSE_CONTROL      0x0D      // Настройки режимов
#define ADNS_CHIP_RESET         0x3A      // Перезагрузка
#define ADNS_SENSOR_CURRENT     0x40      // Контроль тока светодиода подсветки
#define ADNS_REST_MODE          0x45      // Режимы отдыха (О_о)
#define ADNS_MOTION_BRUST       0x63      // Режим непрерывной передачи

// TIMING DELAYs

#define ADNS_DELAY_TSWW         31         // SPI Time between Write Commands
#define ADNS_DELAY_TSRAD        4          // SPI Read Address-Data Delay
#define ADNS_DELAY_TSRWSRR      2          // tSRW & tSRR = 1μs.

#define ARRAY_WIDTH             15
#define ARRAY_HEIGHT            15
#define NUM_PIXS                (ARRAY_WIDTH * ARRAY_HEIGHT)

#define ADNS_PIX_DATA_VALID     0x80      // Бит валидности регистра PIX_GRAB
#define ADNS_MASK_PIX           0x7f      // Маска для работы с 7м битом

byte    frame[NUM_PIXS];                  // Буффер кадра
byte    param[12];                        // Буффер параметров
byte    ter[225];

//////////////////////////////////////  ИНИЦИАЛИЗАЦИЯ  ///////////////////////////////////////
void setup() {
  Serial.begin(9600);
  
  pinMode(NCS, OUTPUT);
  pinMode(SCLK, OUTPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(MISO, INPUT);
  
  digitalWrite(NCS, HIGH);
  digitalWrite(SCLK, HIGH);
  digitalWrite(MOSI, HIGH);
  digitalWrite(MISO, LOW);

  Serial.print('+');
  ADNS_reset();
}
//////////////////////////////////////  ОСНОВНОЙ ЦИКЛ  //////////////////////////////////////
void loop()
{
  params_grab(param);

  int shutter = word(param[5], param[6]);

  Serial.print("###################################/n");
  Serial.print("ADNS_MOTION = ");
  Serial.print(param[1]);
  Serial.print("###################################/n");

  delay(200);
}
/////////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------------------
void ADNS_write(byte address, byte data){           // Шлем адрес и данные через SPI:
  digitalWrite(NCS, LOW);                           // Начинаем передачу
  address |= 0x80;                                  // Выставляем MSB-адреса [1] Признак записи
  
  for (byte i = 0x80; i; i >>= 1){                  // Шлем адрес
    digitalWrite(SCLK, LOW);
    address & i ? digitalWrite(MOSI, HIGH) : digitalWrite(MOSI, LOW);
    asm volatile ("nop");
    digitalWrite(SCLK, HIGH);
  }

  delayMicroseconds(1);                             // Пауза между данными и адресом

  for (byte i = 0x80; i; i >>= 1){                  // Шлем данные
    digitalWrite(SCLK, LOW);
    data & i ? digitalWrite(MOSI, HIGH) : digitalWrite(MOSI, LOW);
    asm volatile ("nop");
    digitalWrite(SCLK, HIGH);
  }
 
  delayMicroseconds(ADNS_DELAY_TSWW);               //tSWW. Задержка SPI между командами записи 
  digitalWrite(NCS, HIGH);                          // Прекращаем передачу
}
//-------------------------------------------------------------------------------------------
byte ADNS_read(byte address){
  digitalWrite(NCS, LOW);                           // Начинаем передачу
  address &= ~0x80;                                 //Выставляем MSB-адреса [0] Признак чтения
  
  for (byte i = 0x80; i; i >>= 1){                  // Шлем адрес
    digitalWrite(SCLK, LOW);
    address & i ? digitalWrite(MOSI, HIGH) : digitalWrite(MOSI, LOW);
    asm volatile ("nop");
    digitalWrite(SCLK, HIGH);
  }

  delayMicroseconds(ADNS_DELAY_TSRAD);              // tSRAD. Задержка чтения адреса-даты

  byte data = 0;                                    // Чистим переменную
  for (byte i = 8; i; i--){                         // Считываем данные
    // tick, tock, read
    digitalWrite(SCLK, LOW);
    asm volatile ("nop");
    digitalWrite(SCLK, HIGH);
    data <<= 1;
    if (digitalRead(MISO)) data |= 0x01;
  }

  digitalWrite(NCS, HIGH);                          // Прекращаем передачу

  delayMicroseconds(ADNS_DELAY_TSRWSRR);
  return data;
}
//-------------------------------------------------------------------------------------------
inline void pixel_grab(uint8_t *buffer, uint16_t nBytes) {
  uint8_t temp_byte;

  ADNS_write(ADNS_PIX_GRAB, 0xFF);                  // Сбрасываем счетчик считанных пикселей

  for (uint16_t count = 0; count < nBytes; count++) 
  {
    while (1)                                       // Проверка на валидность пикселей
    {
      temp_byte = ADNS_read(ADNS_PIX_GRAB);
      if (temp_byte & ADNS_PIX_DATA_VALID) {break;}
    }
    *(buffer + count) = temp_byte & ADNS_MASK_PIX;  // Ограничение количества бит данных
  }
}
//-------------------------------------------------------------------------------------------
inline void params_grab(uint8_t *buffer) {
  *(buffer + 1)    = ADNS_read(ADNS_MOTION);
  *(buffer + 2)    = ADNS_read(ADNS_DELTA_X);
  *(buffer + 3)    = ADNS_read(ADNS_DELTA_Y);
  *(buffer + 4)    = ADNS_read(ADNS_SQUAL);
  *(buffer + 5)    = ADNS_read(ADNS_SHUTTER_UPPER);
  *(buffer + 6)    = ADNS_read(ADNS_SHUTTER_LOWER);
  *(buffer + 7)    = ADNS_read(ADNS_MAX_PIX);
  *(buffer + 8)    = ADNS_read(ADNS_PIX_SUM);
  *(buffer + 9)    = ADNS_read(ADNS_MIN_PIX);
  *(buffer + 10)   = ADNS_read(ADNS_MOUSE_CONTROL);
  *(buffer + 11)   = ADNS_read(ADNS_REST_MODE);
  
}
//-------------------------------------------------------------------------------------------
inline void pixel_and_params_grab(uint8_t *buffer)  // Считываем кадр и параметры
{  
  params_grab((buffer + NUM_PIXS));
  pixel_grab(buffer, NUM_PIXS);
}
//-------------------------------------------------------------------------------------------
void ADNS_reset(void){                              // Сброс сенсора
  ADNS_write(0x3a,0x5a);
  delay(1000);
  ADNS_write(ADNS_MOUSE_CONTROL, 0x01);             // Устанавливаем разрешение в 1000cpi
  delay(1000);
}
