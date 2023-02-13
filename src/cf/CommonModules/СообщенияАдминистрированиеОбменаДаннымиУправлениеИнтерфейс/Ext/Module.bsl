﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Пространство имен текущей (используемой вызывающим кодом) версии интерфейса сообщений.
//
// Возвращаемое значение:
//   Строка - пространство имен.
//
Функция Пакет() Экспорт
	
	Возврат "http://www.1c.ru/SaaS/ExchangeAdministration/Manage";
	
КонецФункции

// Текущая (используемая вызывающим кодом) версия интерфейса сообщений.
//
// Возвращаемое значение:
//   Строка - версия интерфейса сообщений.
//
Функция Версия() Экспорт
	
	Возврат "2.1.2.1";
	
КонецФункции

// Название программного интерфейса сообщений.
//
// Возвращаемое значение:
//   Строка - название программного интерфейса сообщений.
//
Функция ПрограммныйИнтерфейс() Экспорт
	
	Возврат "ExchangeAdministrationManage";
	
КонецФункции

// Выполняет регистрацию обработчиков сообщений в качестве обработчиков каналов обмена сообщениями.
//
// Параметры:
//   МассивОбработчиков - Массив из ОбщийМодуль - коллекция модулей, содержащих обработчики.
//
Процедура ОбработчикиКаналовСообщений(Знач МассивОбработчиков) Экспорт
	
	МассивОбработчиков.Добавить(СообщенияАдминистрированиеОбменаДаннымиУправлениеОбработчикСообщения_2_1_2_1);
	
КонецПроцедуры

// Выполняет регистрацию обработчиков трансляции сообщений.
//
// Параметры:
//   МассивОбработчиков - Массив из ОбщийМодуль - коллекция модулей, содержащих обработчики.
//
Процедура ОбработчикиТрансляцииСообщений(Знач МассивОбработчиков) Экспорт
	
КонецПроцедуры

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}ConnectCorrespondent
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеПодключитьКорреспондента(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "ConnectCorrespondent");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}SetTransportParams
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеУстановитьНастройкиТранспорта(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "SetTransportParams");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}GetSyncSettings
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеПолучитьНастройкиСинхронизацииДанных(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "GetSyncSettings");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}DeleteSync
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеУдалитьНастройкуСинхронизации(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "DeleteSync");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}EnableSync
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеВключитьСинхронизацию(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "EnableSync");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}DisableSync
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеОтключитьСинхронизацию(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "DisableSync");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}PushSync
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеПротолкнутьСинхронизацию(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "PushSync");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}PushTwoApplicationSync
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеПротолкнутьСинхронизациюДвухПриложений(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "PushTwoApplicationSync");
	
КонецФункции

// Возвращает тип сообщения {http://www.1c.ru/SaaS/ExchangeAdministration/Manage/a.b.c.d}ExecuteSync
//
// Параметры:
//   ИспользуемыйПакет - Строка - пространство имен версии интерфейса сообщений, для которой
//                                получается тип сообщения.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - тип объекта сообщения.
//
Функция СообщениеВыполнитьСинхронизацию(Знач ИспользуемыйПакет = Неопределено) Экспорт
	
	Возврат СоздатьТипСообщения(ИспользуемыйПакет, "ExecuteSync");
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция СоздатьТипСообщения(Знач ИспользуемыйПакет, Знач Тип)
	
	Если ИспользуемыйПакет = Неопределено Тогда
		ИспользуемыйПакет = Пакет();
	КонецЕсли;
	
	Возврат ФабрикаXDTO.Тип(ИспользуемыйПакет, Тип);
	
КонецФункции

#КонецОбласти
