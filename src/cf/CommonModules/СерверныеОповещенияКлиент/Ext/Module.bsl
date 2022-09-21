﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Параметры:
//  Интервал - Число
//
Процедура ПодключитьОбработчикПроверкиПолученияСерверныхОповещений(Интервал = 1) Экспорт
	
	Если Интервал < 1 Тогда
		Интервал = 1;
	ИначеЕсли Интервал > 60 Тогда
		Интервал = 60;
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("ОбработчикПроверкиПолученияСерверныхОповещений", Интервал, Истина);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияКлиентПереопределяемый.ПередНачаломРаботыСистемы.
Процедура ПередНачаломРаботыСистемы(Параметры) Экспорт
	
	ПараметрыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	
	Если Не ПараметрыКлиента.Свойство("СерверныеОповещения") Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыСерверныхОповещений = ПараметрыКлиента.СерверныеОповещения; // см. СерверныеОповещения.ПараметрыСерверныхОповещенийЭтогоСеанса
	СостояниеПолучения = СостояниеПолучения();
	ЗаполнитьЗначенияСвойств(СостояниеПолучения, ПараметрыСерверныхОповещений);
	Параметры.ПолученныеПараметрыКлиента.Вставить("СерверныеОповещения");
	Параметры.КоличествоПолученныхПараметровКлиента = Параметры.КоличествоПолученныхПараметровКлиента + 1;
	
	ДатаСеанса = ОбщегоНазначенияКлиент.ДатаСеанса();
	СостояниеПолучения.ДатаОбновленияСостояния = ДатаСеанса;
	СостояниеПолучения.ДатаПоследнегоПолученияСообщения = ДатаСеанса;
	СостояниеПолучения.ДатаПоследнейПериодическойОтправкиДанных = ДатаСеанса;
	
	СостояниеПолучения.ПроверкаРазрешена = Истина;
	ПодключитьОбработчикПроверкиПолученияСерверныхОповещений();
	
КонецПроцедуры

// См. ОбщегоНазначенияКлиентПереопределяемый.ПослеНачалаРаботыСистемы.
Процедура ПослеНачалаРаботыСистемы() Экспорт
	
	СостояниеПолучения = СостояниеПолучения();
	
	Если СостояниеПолучения.СеансАдминистратораСервиса Тогда
		Возврат;
	КонецЕсли;
	
	СостояниеПолучения.ПериодическаяОтправкаДанныхРазрешена = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПроверитьПолучитьСерверныеОповещения() Экспорт
	
	СостояниеПолучения = СостояниеПолучения();
	Если Не СостояниеПолучения.ПроверкаРазрешена Тогда
		Возврат;
	КонецЕсли;
	
	Интервал = СостояниеПолучения.МинимальныйПериод;
	ОбсужденияАктивны = СостояниеПолучения.СистемаВзаимодействийПодключена
		И СостояниеПолучения.ОбработчикНовыхЛичныхСообщенийПодключен
		И СостояниеПолучения.ДатаПоследнегоПолученияСообщения + 60 > ОбщегоНазначенияКлиент.ДатаСеанса();
	
	ДополнительныеПараметры = Новый Соответствие;
	ИмяКлючаПараметровОбсуждений = "СтандартныеПодсистемы.БазоваяФункциональность.ИдентификаторыОбсуждений";
	
	ДлительныеОперацииКлиент.ПередПериодическойОтправкойДанныхКлиентаНаСервер(ДополнительныеПараметры,
		ОбсужденияАктивны, Интервал);
	
	ТекущаяДатаСеанса = ОбщегоНазначенияКлиент.ДатаСеанса();
	ПериодическаяОтправкаДанных = Ложь;
	
	Если СостояниеПолучения.ДатаПоследнейПериодическойОтправкиДанных + 60 < ТекущаяДатаСеанса Тогда
		Если СостояниеПолучения.ПериодическаяОтправкаДанныхРазрешена Тогда
			ИнтеграцияПодсистемБСПКлиент.ПередПериодическойОтправкойДанныхКлиентаНаСервер(ДополнительныеПараметры);
			ОбщегоНазначенияКлиентПереопределяемый.ПередПериодическойОтправкойДанныхКлиентаНаСервер(ДополнительныеПараметры);
			ПериодическаяОтправкаДанных = Истина;
		КонецЕсли;
		СостояниеПолучения.ДатаПоследнейПериодическойОтправкиДанных = ТекущаяДатаСеанса;
		СообщенияДляЖурналаРегистрации = ПараметрыПриложения["СтандартныеПодсистемы.СообщенияДляЖурналаРегистрации"];
		Если СостояниеПолучения.ИдентификаторЛичногоОбсуждения = Неопределено
		   И СистемаВзаимодействия.ИнформационнаяБазаЗарегистрирована() Тогда
			ДополнительныеПараметры.Вставить(ИмяКлючаПараметровОбсуждений, Ложь);
		КонецЕсли;
	КонецЕсли;
	
	Если ОповещенияПолучены(СостояниеПолучения)
	   И Не ЗначениеЗаполнено(ДополнительныеПараметры)
	   И Не ЗначениеЗаполнено(СообщенияДляЖурналаРегистрации) Тогда
		
		ПодключитьОбработчикПроверкиПолученияСерверныхОповещений(Интервал);
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
		МодульСоединенияИБКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("СоединенияИБКлиент");
		МодульСоединенияИБКлиент.ПередПериодическойОтправкойДанныхКлиентаНаСервер(ДополнительныеПараметры);
	КонецЕсли;
	
	ПараметрыОбщегоВызова = НовыеПараметрыОбщегоСерверногоВызова();
	ПараметрыОбщегоВызова.ДатаПоследнегоОповещения    = СостояниеПолучения.ДатаПоследнегоОповещения;
	ПараметрыОбщегоВызова.МинимальныйПериодПроверки   = СостояниеПолучения.МинимальныйПериод;
	ПараметрыОбщегоВызова.ДополнительныеПараметры     = ДополнительныеПараметры;
	ПараметрыОбщегоВызова.ПериодическаяОтправкаДанных = ПериодическаяОтправкаДанных;
	ПараметрыОбщегоВызова.СообщенияДляЖурналаРегистрации =
		ПараметрыПриложения["СтандартныеПодсистемы.СообщенияДляЖурналаРегистрации"];
	
	РезультатОбщегоВызова = СерверныеОповещенияСлужебныйВызовСервера.НедоставленныеСерверныеОповещенияСеанса(
		ПараметрыОбщегоВызова);
	
	Если ПараметрыОбщегоВызова.СообщенияДляЖурналаРегистрации <> Неопределено Тогда
		ПараметрыОбщегоВызова.СообщенияДляЖурналаРегистрации.Очистить();
	КонецЕсли;
	
	ДополнительныеРезультаты = РезультатОбщегоВызова.ДополнительныеРезультаты;
	ИдентификаторыОбсуждений = ДополнительныеРезультаты.Получить(ИмяКлючаПараметровОбсуждений);
	Если ИдентификаторыОбсуждений <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(СостояниеПолучения, ИдентификаторыОбсуждений);
		ПодключитьОбработчикНовыхСообщений(СостояниеПолучения);
	КонецЕсли;
	
	Для Каждого СерверноеОповещение Из РезультатОбщегоВызова.СерверныеОповещения Цикл
		ОбработатьСерверноеОповещениеНаКлиенте(СостояниеПолучения, СерверноеОповещение);
	КонецЦикла;
	
	ДлительныеОперацииКлиент.ПослеПериодическогоПолученияДанныхКлиентаНаСервере(
		ДополнительныеРезультаты, ОбсужденияАктивны, Интервал);
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
		МодульСоединенияИБКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("СоединенияИБКлиент");
		МодульСоединенияИБКлиент.ПослеПериодическогоПолученияДанныхКлиентаНаСервере(
			ДополнительныеРезультаты);
	КонецЕсли;
	
	Если ПериодическаяОтправкаДанных Тогда
		ИнтеграцияПодсистемБСПКлиент.ПослеПериодическогоПолученияДанныхКлиентаНаСервере(
			ДополнительныеРезультаты);
		ОбщегоНазначенияКлиентПереопределяемый.ПослеПериодическогоПолученияДанныхКлиентаНаСервере(
			ДополнительныеРезультаты);
	КонецЕсли;
	
	СостояниеПолучения.ДатаПоследнегоОповещения        = РезультатОбщегоВызова.ДатаПоследнегоОповещения;
	СостояниеПолучения.МинимальныйПериод               = РезультатОбщегоВызова.МинимальныйПериодПроверки;
	СостояниеПолучения.СистемаВзаимодействийПодключена = РезультатОбщегоВызова.СистемаВзаимодействийПодключена;
	СостояниеПолучения.ДатаОбновленияСостояния         = ОбщегоНазначенияКлиент.ДатаСеанса();
	
	Если Интервал > СостояниеПолучения.МинимальныйПериод Тогда
		Интервал = СостояниеПолучения.МинимальныйПериод;
	КонецЕсли;
	
	ПодключитьОбработчикПроверкиПолученияСерверныхОповещений(Интервал);
	
КонецПроцедуры

Процедура ОбработатьСерверноеОповещениеНаКлиенте(СостояниеПолучения, СерверноеОповещение)
	
	Если ОповещениеУжеПолучено(СостояниеПолучения, СерверноеОповещение) Тогда
		Возврат;
	КонецЕсли;
	
	ИмяОповещения = СерверноеОповещение.ИмяОповещения;
	Результат     = СерверноеОповещение.Результат;
	
	Оповещение = СостояниеПолучения.Оповещения.Получить(ИмяОповещения);
	Если Оповещение = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	МодульОбработки = ОбщегоНазначенияКлиент.ОбщийМодуль(Оповещение.ИмяМодуляПолучения);
	Попытка
		МодульОбработки.ПриПолученииСерверногоОповещения(ИмяОповещения, Результат);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'При вызове процедуры ""%1"" возникла ошибка:
			           |%2'"),
			Оповещение.ИмяМодуляПолучения + ".ПриПолученииСерверногоОповещения",
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
		ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(
			НСтр("ru = 'Серверные оповещения.Ошибка обработки полученного оповещения'",
				ОбщегоНазначенияКлиент.КодОсновногоЯзыка()),
			"Ошибка",
			ТекстОшибки);
	КонецПопытки;
	
КонецПроцедуры

Функция ОповещенияПолучены(СостояниеПолучения)
	
	ПодключитьОбработчикНовыхСообщений(СостояниеПолучения);
	
	Граница = СостояниеПолучения.ДатаОбновленияСостояния + СостояниеПолучения.МинимальныйПериод;
	
	Запас = Граница - ОбщегоНазначенияКлиент.ДатаСеанса();
	
	Если Запас > 0 Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// См. НовоеСостояниеПолучения
Функция СостояниеПолучения() Экспорт
	
	ИмяПараметраПриложения = "СтандартныеПодсистемы.БазоваяФункциональность.СерверныеОповещения";
	СостояниеПолучения = ПараметрыПриложения.Получить(ИмяПараметраПриложения);
	Если СостояниеПолучения = Неопределено Тогда
		СостояниеПолучения = НовоеСостояниеПолучения();
		ПараметрыПриложения.Вставить(ИмяПараметраПриложения, СостояниеПолучения);
	КонецЕсли;
	
	Возврат СостояниеПолучения;
	
КонецФункции

// Возвращаемое значение:
//  Структура:
//   * ДатаПоследнегоОповещения - Дата
//   * МинимальныйПериодПроверки - Число
//   * ДополнительныеПараметры - Соответствие
//   * СообщенияДляЖурналаРегистрации - Неопределено, СписокЗначений
//   * ПериодическаяОтправкаДанных - Булево
//
Функция НовыеПараметрыОбщегоСерверногоВызова() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ДатаПоследнегоОповещения",  '00010101');
	Результат.Вставить("МинимальныйПериодПроверки", 60);
	Результат.Вставить("ДополнительныеПараметры", Новый Соответствие);
	Результат.Вставить("СообщенияДляЖурналаРегистрации", Неопределено);
	Результат.Вставить("ПериодическаяОтправкаДанных", Ложь);
	
	Возврат Результат;
	
КонецФункции

// Возвращаемое значение:
//  Структура:
//   * ПроверкаРазрешена - Булево - устанавливается Истина в процедуре ПередНачаломРаботыСистемы.
//   * СеансАдминистратораСервиса - Булево
//   * ПериодическаяОтправкаДанныхРазрешена - Булево - устанавливается Истина в процедуре ПослеНачалаРаботыСистемы.
//   * ПроверкаВыполняется - Булево
//   * КлючСеанса - см. СерверныеОповещения.КлючСеанса
//   * ИдентификаторПользователяИБ - УникальныйИдентификатор
//   * ДатаОбновленияСостояния - Дата
//   * ДатаПоследнегоПолученияСообщения - Дата
//   * МинимальныйПериод - Число - число секунд.
//   * ДатаПоследнегоОповещения - Дата
//   * Оповещения - см. ОбщегоНазначенияПереопределяемый.ПриДобавленииСерверныхОповещений.Оповещения
//   * ПолученныеОповещения - Массив из Строка - строки уникальных идентификаторов полученных сообщений.
//   * СистемаВзаимодействийПодключена - Булево
//   * ИдентификаторЛичногоОбсуждения - Неопределено - обсуждение недоступно.
//                                    - ИдентификаторОбсужденияСистемыВзаимодействия - идентификатор
//        обсуждения "СерверныеОповещения <Идентификатор пользователя ИБ>".
//
//   * ИдентификаторОбщегоОбсуждения - Неопределено - обсуждение недоступно.
//                                   - ИдентификаторОбсужденияСистемыВзаимодействия - идентификатор
//        обсуждения "СерверныеОповещения".
//   * ИдентификаторЛичногоОбсуждения - Строка - строка уникального идентификатора
//        обсуждения "СерверныеОповещения <Идентификатор пользователя ИБ>".
//   * ИдентификаторОбщегоОбсуждения  - Строка - строка уникального идентификатора
//        обсуждения "СерверныеОповещения".
//   * ОбработчикНовыхЛичныхСообщенийПодключен - Булево
//   * ОбработчикНовыхОбщихСообщенийПодключен - Булево
//   * НачатоПодключениеОбработчикаНовыхЛичныхСообщений - Булево
//   * НачатоПодключениеОбработчикаНовыхОбщихСообщений - Булево
//   * ДатаПоследнейПериодическойОтправкиДанных - Дата
//
Функция НовоеСостояниеПолучения()
	
	Состояние = Новый Структура;
	Состояние.Вставить("ПроверкаРазрешена", Ложь);
	Состояние.Вставить("СеансАдминистратораСервиса", Ложь);
	Состояние.Вставить("ПериодическаяОтправкаДанныхРазрешена", Ложь);
	Состояние.Вставить("ПроверкаВыполняется", Ложь);
	Состояние.Вставить("КлючСеанса", "");
	Состояние.Вставить("ИдентификаторПользователяИБ",
		ОбщегоНазначенияКлиентСервер.ПустойУникальныйИдентификатор());
	Состояние.Вставить("ДатаОбновленияСостояния", '00010101');
	Состояние.Вставить("ДатаПоследнегоПолученияСообщения", '00010101');
	Состояние.Вставить("МинимальныйПериод", 60);
	Состояние.Вставить("ДатаПоследнегоОповещения", '00010101');
	Состояние.Вставить("Оповещения", Новый Соответствие);
	Состояние.Вставить("ПолученныеОповещения", Новый Массив);
	Состояние.Вставить("СистемаВзаимодействийПодключена", Ложь);
	Состояние.Вставить("ИдентификаторЛичногоОбсуждения", Неопределено);
	Состояние.Вставить("ИдентификаторОбщегоОбсуждения", Неопределено);
	Состояние.Вставить("ОбработчикНовыхЛичныхСообщенийПодключен", Ложь);
	Состояние.Вставить("ОбработчикНовыхОбщихСообщенийПодключен", Ложь);
	Состояние.Вставить("НачатоПодключениеОбработчикаНовыхЛичныхСообщений", Ложь);
	Состояние.Вставить("НачатоПодключениеОбработчикаНовыхОбщихСообщений", Ложь);
	Состояние.Вставить("ДатаПоследнейПериодическойОтправкиДанных", '00010101');
	
	Возврат Состояние;
	
КонецФункции

Процедура ПодключитьОбработчикНовыхСообщений(СостояниеПолучения)
	
	Если СостояниеПолучения.ИдентификаторЛичногоОбсуждения <> Неопределено
	   И Не СостояниеПолучения.ОбработчикНовыхЛичныхСообщенийПодключен
	   И Не СостояниеПолучения.НачатоПодключениеОбработчикаНовыхЛичныхСообщений Тогда
		
		Контекст = Новый Структура("СостояниеПолучения", СостояниеПолучения);
		Попытка
			СистемаВзаимодействия.НачатьПодключениеОбработчикаНовыхСообщений(
				Новый ОписаниеОповещения("ПослеПодключенияОбработчикаНовыхЛичныхСообщений", ЭтотОбъект, Контекст,
					"ПослеОшибкиПодключенияОбработчикаНовыхЛичныхСообщений", ЭтотОбъект),
				Новый ИдентификаторОбсужденияСистемыВзаимодействия(СостояниеПолучения.ИдентификаторЛичногоОбсуждения),
				Новый ОписаниеОповещения("ПриПолученииНовогоЛичногоСообщенияСистемыВзаимодействия", ЭтотОбъект, Контекст,
					"ПриОшибкеПолученияНовогоЛичногоСообщенияСистемыВзаимодействия", ЭтотОбъект),
				Неопределено);
		Исключение
			ПослеОшибкиПодключенияОбработчикаНовыхЛичныхСообщений(ИнформацияОбОшибке(), Ложь, Контекст);
		КонецПопытки;
	КонецЕсли;
	
	Если СостояниеПолучения.ИдентификаторОбщегоОбсуждения <> Неопределено
	   И Не СостояниеПолучения.ОбработчикНовыхОбщихСообщенийПодключен
	   И Не СостояниеПолучения.НачатоПодключениеОбработчикаНовыхОбщихСообщений Тогда
		
		Контекст = Новый Структура("СостояниеПолучения", СостояниеПолучения);
		Попытка
			СистемаВзаимодействия.НачатьПодключениеОбработчикаНовыхСообщений(
				Новый ОписаниеОповещения("ПослеПодключенияОбработчикаНовыхОбщихСообщений", ЭтотОбъект, Контекст,
					"ПослеОшибкиПодключенияОбработчикаНовыхОбщихСообщений", ЭтотОбъект),
				Новый ИдентификаторОбсужденияСистемыВзаимодействия(СостояниеПолучения.ИдентификаторОбщегоОбсуждения),
				Новый ОписаниеОповещения("ПриПолученииНовогоОбщегоСообщенияСистемыВзаимодействия", ЭтотОбъект, Контекст,
					"ПриОшибкеПолученияНовогоОбщегоСообщенияСистемыВзаимодействия", ЭтотОбъект),
				Неопределено);
		Исключение
			ПослеОшибкиПодключенияОбработчикаНовыхОбщихСообщений(ИнформацияОбОшибке(), Ложь, Контекст);
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

Процедура ПослеПодключенияОбработчикаНовыхЛичныхСообщений(Контекст) Экспорт
	
	Контекст.СостояниеПолучения.НачатоПодключениеОбработчикаНовыхЛичныхСообщений = Ложь;
	Контекст.СостояниеПолучения.ОбработчикНовыхЛичныхСообщенийПодключен = Истина;
	
КонецПроцедуры

Процедура ПослеОшибкиПодключенияОбработчикаНовыхЛичныхСообщений(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	Контекст.СостояниеПолучения.НачатоПодключениеОбработчикаНовыхЛичныхСообщений = Ложь;
	
	ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(
		НСтр("ru = 'Серверные оповещения.Ошибка подключения обработчика новых личных сообщений'",
			ОбщегоНазначенияКлиент.КодОсновногоЯзыка()),
		"Ошибка",
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
КонецПроцедуры

Процедура ПриПолученииНовогоЛичногоСообщенияСистемыВзаимодействия(Сообщение, Контекст) Экспорт
	
	ПриПолученииНовогоСообщенияСистемыВзаимодействия(Сообщение, Контекст);
	
КонецПроцедуры

Процедура ПриОшибкеПолученияНовогоЛичногоСообщенияСистемыВзаимодействия(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(
		НСтр("ru = 'Серверные оповещения.Ошибка получения нового личного сообщения'",
			ОбщегоНазначенияКлиент.КодОсновногоЯзыка()),
		"Ошибка",
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
КонецПроцедуры

Процедура ПослеПодключенияОбработчикаНовыхОбщихСообщений(Контекст) Экспорт
	
	Контекст.СостояниеПолучения.НачатоПодключениеОбработчикаНовыхОбщихСообщений = Ложь;
	Контекст.СостояниеПолучения.ОбработчикНовыхОбщихСообщенийПодключен = Истина;
	
КонецПроцедуры

Процедура ПослеОшибкиПодключенияОбработчикаНовыхОбщихСообщений(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	Контекст.СостояниеПолучения.НачатоПодключениеОбработчикаНовыхОбщихСообщений = Ложь;
	
	ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(
		НСтр("ru = 'Серверные оповещения.Ошибка подключения обработчика новых общих сообщений'",
			ОбщегоНазначенияКлиент.КодОсновногоЯзыка()),
		"Ошибка",
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
КонецПроцедуры

Процедура ПриПолученииНовогоОбщегоСообщенияСистемыВзаимодействия(Сообщение, Контекст) Экспорт
	
	ПриПолученииНовогоСообщенияСистемыВзаимодействия(Сообщение, Контекст);
	
КонецПроцедуры

Процедура ПриОшибкеПолученияНовогоОбщегоСообщенияСистемыВзаимодействия(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	ЖурналРегистрацииКлиент.ДобавитьСообщениеДляЖурналаРегистрации(
		НСтр("ru = 'Серверные оповещения.Ошибка получения нового общего сообщения'",
			ОбщегоНазначенияКлиент.КодОсновногоЯзыка()),
		"Ошибка",
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
КонецПроцедуры

Процедура ПриПолученииНовогоСообщенияСистемыВзаимодействия(Сообщение, Контекст)
	
	СостояниеПолучения = Контекст.СостояниеПолучения;
	
	Если Не СостояниеПолучения.ПроверкаРазрешена
	 Или ПараметрыПриложения = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СостояниеПолучения.ДатаПоследнегоПолученияСообщения = ОбщегоНазначенияКлиент.ДатаСеанса();
	
	Если ТипЗнч(Сообщение.Данные) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	Данные = Сообщение.Данные; // См. СерверныеОповещения.НовыеДанныеСообщения
	Если Не Данные.Свойство("ИмяОповещения") Тогда
		Возврат;
	КонецЕсли;
	
	Если Данные.ИмяОповещения <> "НетСерверныхОповещений" Тогда
		Если Данные.Адресаты <> Неопределено Тогда
			КлючиСеансов = Данные.Адресаты.Получить(СостояниеПолучения.ИдентификаторПользователяИБ);
			Если ТипЗнч(КлючиСеансов) <> Тип("Массив")
			 Или КлючиСеансов.Найти(СостояниеПолучения.КлючСеанса) = Неопределено
			   И КлючиСеансов.Найти("*") = Неопределено Тогда
				Возврат;
			КонецЕсли;
		КонецЕсли;
		ОбработатьСерверноеОповещениеНаКлиенте(СостояниеПолучения, Данные);
		Если Не Данные.ОтправленоИзОчереди Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ДатаПоследнегоОповещения = Данные.Ошибки.Получить(СостояниеПолучения.ИдентификаторПользователяИБ);
	Если ДатаПоследнегоОповещения = Неопределено Тогда
		ДатаПоследнегоОповещения = Данные.Ошибки.Получить("ВсеПользователи");
		Если ДатаПоследнегоОповещения = Неопределено Тогда
			ДатаПоследнегоОповещения = Данные.ДатаДобавления;
			СостояниеПолучения.ДатаОбновленияСостояния = ОбщегоНазначенияКлиент.ДатаСеанса();
		КонецЕсли;
	КонецЕсли;
	Если СостояниеПолучения.ДатаПоследнегоОповещения < ДатаПоследнегоОповещения Тогда
		СостояниеПолучения.ДатаПоследнегоОповещения = ДатаПоследнегоОповещения;
	КонецЕсли;
	
КонецПроцедуры

Функция ОповещениеУжеПолучено(СостояниеПолучения, СерверноеОповещение)
	
	Если СерверноеОповещение.ДатаДобавления < СостояниеПолучения.ДатаПоследнегоОповещения Тогда
		Возврат Истина;
	КонецЕсли;
	
	ПолученныеОповещения = СостояниеПолучения.ПолученныеОповещения;
	
	Если ПолученныеОповещения.Найти(СерверноеОповещение.ИдентификаторОповещения) <> Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	ПолученныеОповещения.Добавить(СерверноеОповещение.ИдентификаторОповещения);
	Если ПолученныеОповещения.Количество() > 100 Тогда
		ПолученныеОповещения.Удалить(0);
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти
