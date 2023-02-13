﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Функции-конструкторы разрешений.
//

// Возвращает внутреннее описание разрешения на использование каталога файловой системы.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  Адрес - Строка - адрес ресурса файловой системы,
//  ЧтениеДанных - Булево - указывает необходимость предоставления разрешения
//                          на чтение данных из данного каталога файловой системы.
//  ЗаписьДанных - Булево - указывает необходимость предоставления разрешения
//                          на запись данных в указанный каталог файловой системы.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO 
//
Функция РазрешениеНаИспользованиеКаталогаФайловойСистемы(Знач Адрес, Знач ЧтениеДанных = Ложь, Знач ЗаписьДанных = Ложь, Знач Описание = "") Экспорт
	
	Пакет = РаботаВБезопасномРежимеСлужебный.Пакет();
	Результат = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(Пакет, "FileSystemAccess"));
	Результат.Description = Описание;
	
	Если СтрЗаканчиваетсяНа(Адрес, "\") Или СтрЗаканчиваетсяНа(Адрес, "/") Тогда
		Адрес = Лев(Адрес, СтрДлина(Адрес) - 1);
	КонецЕсли;
	
	Результат.Path = Адрес;
	Результат.AllowedRead = ЧтениеДанных;
	Результат.AllowedWrite = ЗаписьДанных;
	
	Возврат Результат;
	
КонецФункции

// Возвращает внутреннее описание разрешения на использование каталога временных файлов.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  ЧтениеДанных - Булево - указывает необходимость предоставления разрешения
//                          на чтение данных из каталога временных файлов.
//  ЗаписьДанных - Булево - указывает необходимость предоставления разрешения
//                          на запись данных в каталог временных файлов.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаИспользованиеКаталогаВременныхФайлов(Знач ЧтениеДанных = Ложь, Знач ЗаписьДанных = Ложь, Знач Описание = "") Экспорт
	
	Возврат РазрешениеНаИспользованиеКаталогаФайловойСистемы(ПсевдонимКаталогаВременныхФайлов(), ЧтениеДанных, ЗаписьДанных);
	
КонецФункции

// Возвращает внутреннее описание разрешения на использование каталога программы.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  ЧтениеДанных - Булево - указывает необходимость предоставления разрешения
//                          на чтение данных из каталога программы.
//  ЗаписьДанных - Булево - указывает необходимость предоставления разрешения
//                          на запись данных в каталог программы.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаИспользованиеКаталогаПрограммы(Знач ЧтениеДанных = Ложь, Знач ЗаписьДанных = Ложь, Знач Описание = "") Экспорт
	
	Возврат РазрешениеНаИспользованиеКаталогаФайловойСистемы(ПсевдонимКаталогаПрограммы(), ЧтениеДанных, ЗаписьДанных);
	
КонецФункции

// Возвращает внутреннее описание разрешения на использование COM-класса.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  ProgID - Строка - ProgID класса COM, с которым он зарегистрирован в системе.
//                    Например, "Excel.Application".
//  CLSID - Строка - CLSID класса COM, с которым он зарегистрирован в системе.
//  ИмяКомпьютера - Строка - имя компьютера, на котором надо создать указанный объект.
//                           Если не указано, то объект будет создан на компьютере, на котором выполняется
//                           текущий рабочий процесс.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаСозданиеCOMКласса(Знач ProgID, Знач CLSID, Знач ИмяКомпьютера = "", Знач Описание = "") Экспорт
	
	Пакет = РаботаВБезопасномРежимеСлужебный.Пакет();
	Результат = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(Пакет, "CreateComObject"));
	Результат.Description = Описание;
	
	Результат.ProgId = ProgID;
	Результат.CLSID = Строка(CLSID);
	Результат.ComputerName = ИмяКомпьютера;
	
	Возврат Результат;
	
КонецФункции

// Возвращает внутреннее описание разрешения на использование внешней компоненты, поставляемой
// в общем макете конфигурации.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  ИмяМакета - Строка - имя общего макета в конфигурации, в котором поставляется внешняя компонента.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаИспользованиеВнешнейКомпоненты(Знач ИмяМакета, Знач Описание = "") Экспорт
	
	Пакет = РаботаВБезопасномРежимеСлужебный.Пакет();
	Результат = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(Пакет, "AttachAddin"));
	Результат.Description = Описание;
	
	Результат.TemplateName = ИмяМакета;
	
	Возврат Результат;
	
КонецФункции

// Возвращает внутреннее описание разрешения на использование расширения конфигурации.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  Имя - Строка - имя расширения конфигурации.
//  КонтрольнаяСумма - Строка - контрольная сумма расширения конфигурации.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаИспользованиеВнешнегоМодуля(Знач Имя, Знач КонтрольнаяСумма, Знач Описание = "") Экспорт
	
	Пакет = РаботаВБезопасномРежимеСлужебный.Пакет();
	Результат = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(Пакет, "ExternalModule"));
	Результат.Description = Описание;
	
	Результат.Name = Имя;
	Результат.Hash = КонтрольнаяСумма;
	
	Возврат Результат;
	
КонецФункции

// Возвращает внутреннее описание разрешения на использование приложения операционной системы.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  ШаблонСтрокиЗапуска - Строка - шаблон строки запуска приложения.
//                                 Подробнее см. документацию к платформе.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаИспользованиеПриложенияОперационнойСистемы(Знач ШаблонСтрокиЗапуска, Знач Описание = "") Экспорт
	
	Пакет = РаботаВБезопасномРежимеСлужебный.Пакет();
	Результат = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(Пакет, "RunApplication"));
	Результат.Description = Описание;
	
	Результат.CommandMask = ШаблонСтрокиЗапуска;
	
	Возврат Результат;
	
КонецФункции

// Возвращает внутреннее описание разрешения на использование интернет-ресурса.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  Протокол - Строка - протокол, по которому выполняется взаимодействие с ресурсом. Допустимые значения:
//                      IMAP, POP3, SMTP, HTTP, HTTPS, FTP, FTPS, WS, WSS.
//  Адрес - Строка - адрес ресурса без указания протокола.
//  Порт - Число - номер порта через который выполняется взаимодействие с ресурсом.
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаИспользованиеИнтернетРесурса(Знач Протокол, Знач Адрес, Знач Порт = Неопределено, Знач Описание = "") Экспорт
	
	Если Порт = Неопределено Тогда
		СтандартныеПорты = СтандартныеПортыИнтернетПротоколов();
		Если СтандартныеПорты.Свойство(ВРег(Протокол)) <> Неопределено Тогда
			Порт = СтандартныеПорты[ВРег(Протокол)];
		КонецЕсли;
	КонецЕсли;
	
	Пакет = РаботаВБезопасномРежимеСлужебный.Пакет();
	Результат = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(Пакет, "InternetResourceAccess"));
	Результат.Description = Описание;
	
	Результат.Protocol = Протокол;
	Результат.Host = Адрес;
	Результат.Port = Порт;
	
	Возврат Результат;
	
КонецФункции

// Возвращает внутреннее описание разрешения на расширенную работу с данными (включая установку
// привилегированного режима) для внешних модулей.
// Для передачи в качестве параметра в функции:
// РаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов и
// РаботаВБезопасномРежиме.ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов.
//
// Параметры:
//  Описание - Строка - описание причины, по которой требуется предоставление разрешения.
//
// Возвращаемое значение:
//  ОбъектXDTO
//
Функция РазрешениеНаИспользованиеПривилегированногоРежима(Знач Описание = "") Экспорт
	
	Пакет = РаботаВБезопасномРежимеСлужебный.Пакет();
	Результат = ФабрикаXDTO.Создать(ФабрикаXDTO.Тип(Пакет, "ExternalModulePrivilegedModeAllowed"));
	Результат.Description = Описание;
	
	Возврат Результат;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Функции-конструкторы запросов на использование внешних ресурсов.
//

// Создает запрос на использование внешних ресурсов.
//
// Параметры:
//  НовыеРазрешения - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеВнешнегоМодуля 
//                  - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеВнешнейКомпоненты  
//                  - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса  
//                  - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаВременныхФайлов  
//                  - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаПрограммы  
//                  - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаФайловойСистемы  
//                  - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеПривилегированногоРежима  
//					- Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеПриложенияОперационнойСистемы - 
//					  запрашиваемые разрешения на доступ к внешним ресурсам.
//  Владелец - ЛюбаяСсылка - ссылка на объект информационной базы, с которой логически связаны запрашиваемые
//    разрешения. Например, все разрешения на доступ к каталогам томов хранения файлов логически связаны
//    с соответствующими элементами справочника ТомаХраненияФайлов, все разрешения на доступ к каталогам
//    обмена данными (или к другим ресурсам в зависимости от используемого транспорта обмена) логически
//    связаны с соответствующими узлами планов обмена и т.д. В том случае, если разрешение является логически
//    обособленным (например, предоставление разрешения регулируется значением константы с типом Булево) -
//    рекомендуется использовать ссылку на элемент справочника ИдентификаторыОбъектовМетаданных.
//  РежимЗамещения - Булево - определяет режим замещения ранее выданных разрешений для данного владельца. При
//    значении параметра равным Истина, помимо предоставления запрошенных разрешений в запрос будет добавлена
//    очистка всех разрешений, ранее запрошенных для этого же владельца.
//
// Возвращаемое значение:
//  УникальныйИдентификатор -  ссылка на записанный в ИБ запрос разрешений. После создания
//    всех запросов на изменение разрешений требуется применить запрошенные изменения с помощью вызова 
//    процедуры РаботаВБезопасномРежимеКлиент.ПрименитьЗапросыНаИспользованиеВнешнихРесурсов.
//
Функция ЗапросНаИспользованиеВнешнихРесурсов(Знач НовыеРазрешения, Знач Владелец = Неопределено, Знач РежимЗамещения = Истина) Экспорт
	
	Возврат РаботаВБезопасномРежимеСлужебный.ЗапросИзмененияРазрешений(
		Владелец,
		РежимЗамещения,
		НовыеРазрешения);
	
КонецФункции

// Создает запрос на отмену разрешений использования внешних ресурсов.
//
// Параметры:
//  Владелец - ЛюбаяСсылка - ссылка на объект информационной базы, с которой логически связаны отменяемые
//    разрешения. Например, все разрешения на доступ к каталогам томов хранения файлов логически связаны
//    с соответствующими элементами справочника ТомаХраненияФайлов, все разрешения на доступ к каталогам
//    обмена данными (или к другим ресурсам в зависимости от используемого транспорта обмена) логически
//    связаны с соответствующими узлами планов обмена и т.д. В том случае, если разрешение является логически
//    обособленным (например, отменяемые разрешения регулируется значением константы с типом Булево) -
//    рекомендуется использовать ссылку на элемент справочника ИдентификаторыОбъектовМетаданных.
//  ОтменяемыеРазрешения - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеВнешнегоМодуля 
//                       - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеВнешнейКомпоненты  
//                       - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса  
//                       - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаВременныхФайлов  
//                       - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаПрограммы  
//                       - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеКаталогаФайловойСистемы  
//                       - Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеПривилегированногоРежима  
//					- Массив из см. РаботаВБезопасномРежиме.РазрешениеНаИспользованиеПриложенияОперационнойСистемы - 
//					  отменяемые разрешения на доступ к внешним ресурсам.
//
// Возвращаемое значение:
//  УникальныйИдентификатор - ссылка на записанный в ИБ запрос разрешений. После создания
//    всех запросов на изменение разрешений требуется применить запрошенные изменения с помощью вызова 
//    процедуры РаботаВБезопасномРежимеКлиент.ПрименитьЗапросыНаИспользованиеВнешнихРесурсов.
//
Функция ЗапросНаОтменуРазрешенийИспользованияВнешнихРесурсов(Знач Владелец, Знач ОтменяемыеРазрешения) Экспорт
	
	Возврат РаботаВБезопасномРежимеСлужебный.ЗапросИзмененияРазрешений(
		Владелец,
		Ложь,
		,
		ОтменяемыеРазрешения);
	
КонецФункции

// Создает запрос на отмену всех разрешений использования внешних ресурсов, связанных в владельцем.
//
// Параметры:
//  Владелец - ЛюбаяСсылка - ссылка на объект информационной базы, с которой логически связаны отменяемые
//    разрешения. Например, все разрешения на доступ к каталогам томов хранения файлов логически связаны
//    с соответствующими элементами справочника ТомаХраненияФайлов, все разрешения на доступ к каталогам
//    обмена данными (или к другим ресурсам в зависимости от используемого транспорта обмена) логически
//    связаны с соответствующими узлами планов обмена и т.д. В том случае, если разрешение является логически
//    обособленным (например, отменяемые разрешения регулируется значением константы с типом Булево) -
//    рекомендуется использовать ссылку на элемент справочника ИдентификаторыОбъектовМетаданных.
//
// Возвращаемое значение:
//  УникальныйИдентификатор - ссылка на записанный в ИБ запрос разрешений. После создания
//    всех запросов на изменение разрешений требуется применить запрошенные изменения с помощью вызова 
//    процедуры РаботаВБезопасномРежимеКлиент.ПрименитьЗапросыНаИспользованиеВнешнихРесурсов.
//
Функция ЗапросНаОчисткуРазрешенийИспользованияВнешнихРесурсов(Знач Владелец) Экспорт
	
	Возврат РаботаВБезопасномРежимеСлужебный.ЗапросИзмененияРазрешений(
		Владелец,
		Истина);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Функции для поддержки работы конфигурации с профилем безопасности, в котором
// запрещено подключение внешних модулей без установки безопасного режима.
//

// Проверят установленность безопасного режима, игнорируя безопасный режим профиля безопасности,
//  использующегося в качестве профиля безопасности с уровнем привилегий конфигурации.
//
// Возвращаемое значение:
//   Булево - Истина, если безопасный режим установлен.
//
Функция УстановленБезопасныйРежим() Экспорт
	
	ТекущийБезопасныйРежим = БезопасныйРежим();
	
	Если ТипЗнч(ТекущийБезопасныйРежим) = Тип("Строка") Тогда
		
		Если Не ДоступенПереходВПривилегированныйРежим() Тогда
			Возврат Истина; // В небезопасном режиме переход в привилегированный режим всегда доступен.
		КонецЕсли;
		
		Попытка
			ПрофильИнформационнойБазы = ПрофильБезопасностиИнформационнойБазы();
		Исключение
			Возврат Истина;
		КонецПопытки;
		
		Возврат (ТекущийБезопасныйРежим <> ПрофильИнформационнойБазы);
		
	ИначеЕсли ТипЗнч(ТекущийБезопасныйРежим) = Тип("Булево") Тогда
		
		Возврат ТекущийБезопасныйРежим;
		
	КонецЕсли;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Прочее
//

// Создает запросы на обновление разрешений конфигурации.
//
// Параметры:
//  ВключаяЗапросСозданияПрофиляИБ - Булево - включать в результат запрос на создание профиля безопасности
//    для текущей информационной базы.
//
// Возвращаемое значение:
//  Массив - идентификаторы запросов для обновления разрешений
//           конфигурации до требуемых в настоящий момент.
//
Функция ЗапросыОбновленияРазрешенийКонфигурации(Знач ВключаяЗапросСозданияПрофиляИБ = Истина) Экспорт
	
	Возврат РаботаВБезопасномРежимеСлужебный.ЗапросыОбновленияРазрешенийКонфигурации(ВключаяЗапросСозданияПрофиляИБ);
	
КонецФункции

// Возвращает контрольные суммы файлов комплекта внешней компоненты, поставляемого в макете конфигурации.
//
// Параметры:
//   ИмяМакета - Строка - имя макета конфигурации, в составе которого поставляется комплект внешней компоненты.
//
// Возвращаемое значение:
//   ФиксированноеСоответствие из КлючИЗначение - контрольные суммы файлов:
//     * Ключ - Строка - имя файла,
//     * Значение - Строка - контрольная сумма.
//
Функция КонтрольныеСуммыФайловКомплектаВнешнейКомпоненты(Знач ИмяМакета) Экспорт
	
	Возврат РаботаВБезопасномРежимеСлужебный.КонтрольныеСуммыФайловКомплектаВнешнейКомпоненты(ИмяМакета);
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ИспользуютсяПрофилиБезопасности() Экспорт
	Возврат ПолучитьФункциональнуюОпцию("ИспользуютсяПрофилиБезопасности");
КонецФункции

// Возвращает имя профиля безопасности, предоставляющего привилегии кода конфигурации.
//
// Возвращаемое значение:
//   Строка
//
Функция ПрофильБезопасностиИнформационнойБазы(ПроверкаИспользования = Ложь) Экспорт
	
	Если ПроверкаИспользования И Не ПолучитьФункциональнуюОпцию("ИспользуютсяПрофилиБезопасности") Тогда
		Возврат "";
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПрофильБезопасности = Константы.ПрофильБезопасностиИнформационнойБазы.Получить();
	
	Если ПрофильБезопасности = Ложь Тогда
		Возврат "";
	КонецЕсли;
	
	Возврат ПрофильБезопасности;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Проверяет возможность перехода в привилегированный режим из текущего безопасного режима.
//
// Возвращаемое значение:
//   Булево
//
Функция ДоступенПереходВПривилегированныйРежим()
	
	УстановитьПривилегированныйРежим(Истина);
	Возврат ПривилегированныйРежим();
	
КонецФункции

// Возвращает "предопределенный" псевдоним (alias) для каталога программы.
//
// Возвращаемое значение:
//   Строка
//
Функция ПсевдонимКаталогаПрограммы()
	
	Возврат "/bin";
	
КонецФункции

// Возвращает "предопределенный" псевдоним (alias) для каталога временных файлов.
//
Функция ПсевдонимКаталогаВременныхФайлов()
	
	Возврат "/temp";
	
КонецФункции

// Возвращает стандартные сетевые порты для Интернет-протоколов, инструменты для использования которых
// есть во встроенном языке 1С:Предприятия. Используется для определения сетевого порта в тех
// случаях, когда из прикладного кода запрашивается разрешение без указания сетевого порта.
//
// Возвращаемое значение:
//   ФиксированнаяСтруктура:
//    * IMAP - Число - 143. 
//    * POP3 - Число - 110.
//    * SMTP - Число - 25.
//    * HTTP - Число - 80.
//    * HTTPS - Число - 443.
//    * FTP - Число - 21.
//    * FTPS - Число - 21.
//    * WS - Число - 80.
//    * WSS - Число - 443.
//
Функция СтандартныеПортыИнтернетПротоколов()
	
	Результат = Новый Структура();
	
	Результат.Вставить("IMAP",  143);
	Результат.Вставить("POP3",  110);
	Результат.Вставить("SMTP",  25);
	Результат.Вставить("HTTP",  80);
	Результат.Вставить("HTTPS", 443);
	Результат.Вставить("FTP",   21);
	Результат.Вставить("FTPS",  21);
	Результат.Вставить("WS",    80);
	Результат.Вставить("WSS",   443);
	
	Возврат Новый ФиксированнаяСтруктура(Результат);
	
КонецФункции

#КонецОбласти

