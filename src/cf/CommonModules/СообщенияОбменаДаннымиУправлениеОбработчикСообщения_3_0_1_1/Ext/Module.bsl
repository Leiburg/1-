﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Пространство имен версии интерфейса сообщений.
//
// Возвращаемое значение:
//   Строка - пространство имен.
//
Функция Пакет() Экспорт
	
	Возврат "http://www.1c.ru/SaaS/Exchange/Manage/3.0.1.1";
	
КонецФункции

// Версия интерфейса сообщений, обслуживаемая обработчиком.
//
// Возвращаемое значение:
//   Строка - версия интерфейса сообщений.
//
Функция Версия() Экспорт
	
	Возврат "3.0.1.1";
	
КонецФункции

// Базовый тип для сообщений версии.
//
// Возвращаемое значение:
//   ТипОбъектаXDTO - базовый тип тела сообщения.
//
Функция БазовыйТип() Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		ВызватьИсключение НСтр("ru = 'Отсутствует менеджер сервиса.'");
	КонецЕсли;
	
	МодульСообщенияВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("СообщенияВМоделиСервиса");
	
	Возврат МодульСообщенияВМоделиСервиса.ТипТело();
	
КонецФункции

// Выполняет обработку входящих сообщений модели сервиса
//
// Параметры:
//   Сообщение   - ОбъектXDTO - входящее сообщение.
//   Отправитель - ПланОбменаСсылка.ОбменСообщениями - узел плана обмена, соответствующий отправителю сообщения.
//   СообщениеОбработано - Булево - флаг успешной обработки сообщения. Значение данного параметра необходимо
//                         установить равным Истина в том случае, если сообщение было успешно прочитано в данном обработчике.
//
Процедура ОбработатьСообщениеМоделиСервиса(Знач Сообщение, Знач Отправитель, СообщениеОбработано) Экспорт
	
	СообщениеОбработано = Истина;
	
	Словарь = СообщенияОбменаДаннымиУправлениеИнтерфейс;
	ТипСообщения = Сообщение.Body.Тип();
	
	Если ТипСообщения = Словарь.СообщениеНастроитьОбменШаг1(Пакет()) Тогда
		
		НастроитьОбменШаг1(Сообщение, Отправитель);
		
	ИначеЕсли ТипСообщения = Словарь.СообщениеЗагрузитьСообщениеОбмена(Пакет()) Тогда
		
		ЗагрузитьСообщениеОбмена(Сообщение, Отправитель);
		
	ИначеЕсли ТипСообщения = Словарь.СообщениеПолучитьДанныеКорреспондента(Пакет()) Тогда
		
		ПолучитьДанныеКорреспондента(Сообщение, Отправитель);
		
	ИначеЕсли ТипСообщения = Словарь.СообщениеПолучитьОбщиеДанныеУзловКорреспондента(Пакет()) Тогда
		
		ПолучитьОбщиеДанныеУзловКорреспондента(Сообщение, Отправитель);
		
	ИначеЕсли ТипСообщения = Словарь.СообщениеПолучитьПараметрыУчетаКорреспондента(Пакет()) Тогда
		
		ПолучитьПараметрыУчетаКорреспондента(Сообщение, Отправитель);
		
	Иначе
		
		СообщениеОбработано = Ложь;
		Возврат;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура НастроитьОбменШаг1(Сообщение, Отправитель) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		Возврат;
	КонецЕсли;
		
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	МодульСообщенияВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("СообщенияВМоделиСервиса");
	
	Тело = Сообщение.Body;
	
	КодЭтогоУзла = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ПланыОбмена[Тело.ExchangePlan].ЭтотУзел(), "Код");
	ПсевдонимЭтогоУзла = "";
	
	Если Не ПустаяСтрока(КодЭтогоУзла) И КодЭтогоУзла <> Тело.Code Тогда
		ПсевдонимЭтогоУзла = ОбменДаннымиВМоделиСервиса.КодУзлаПланаОбменаВСервисе(МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
	
		Если ПсевдонимЭтогоУзла <> Тело.Code Тогда
			СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ожидаемый код предопределенного узла в этом приложении ""%1""
				|не соответствует фактическому ""%2"" или псевдониму ""%3"". План обмена: %4.'"),
				Тело.Code, КодЭтогоУзла, ПсевдонимЭтогоУзла, Тело.ExchangePlan);
			ВызватьИсключение СтрокаСообщения;
		КонецЕсли;
	КонецЕсли;
	
	КонечнаяТочкаКорреспондента = ОбменДаннымиВМоделиСервиса.МенеджерПланаОбменаКонечныхТочек().НайтиПоКоду(Тело.EndPoint);
	
	Если КонечнаяТочкаКорреспондента.Пустая() Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не найдена конечная точка корреспондента с кодом ""%1"".'"),
			Тело.EndPoint);
	КонецЕсли;
	
	Префикс = "";
	ПрефиксКорреспондента = "";
	ИдентификаторНастройки = "";
	
	Если Сообщение.Установлено("AdditionalInfo") Тогда
		ДополнительныеСвойства = СериализаторXDTO.ПрочитатьXDTO(Сообщение.AdditionalInfo);
		Если ДополнительныеСвойства.Свойство("Префикс") Тогда
			Префикс = ДополнительныеСвойства.Префикс;
		КонецЕсли;
		Если ДополнительныеСвойства.Свойство("ПрефиксКорреспондента") Тогда
			ПрефиксКорреспондента = ДополнительныеСвойства.ПрефиксКорреспондента;
		КонецЕсли;
		Если ДополнительныеСвойства.Свойство("ИдентификаторНастройки") Тогда
			ИдентификаторНастройки = ДополнительныеСвойства.ИдентификаторНастройки;
		КонецЕсли;
	КонецЕсли;
	
	НастройкиXDTOКорреспондента = Новый Структура;
	
	НастройкиОтбора = СериализаторXDTO.ПрочитатьXDTO(Тело.FilterSettings);
	Если НастройкиОтбора.Свойство("НастройкиXDTOКорреспондента") Тогда
		НастройкиXDTOКорреспондента = НастройкиОтбора.НастройкиXDTOКорреспондента;
	КонецЕсли;
	
	// Создаем настройку обмена.
	НастройкиПодключения = Новый Структура;
	НастройкиПодключения.Вставить("ИмяПланаОбмена", Тело.ExchangePlan);
	НастройкиПодключения.Вставить("ИдентификаторНастройки", ИдентификаторНастройки);
	
	НастройкиПодключения.Вставить("Наименование", ""); // не требуется
	НастройкиПодключения.Вставить("НаименованиеКорреспондента", Тело.CorrespondentName);
	
	НастройкиПодключения.Вставить("Префикс",               Префикс);
	НастройкиПодключения.Вставить("ПрефиксКорреспондента", ПрефиксКорреспондента);
	
	НастройкиПодключения.Вставить("ИдентификаторИнформационнойБазыИсточника", КодЭтогоУзла);
	НастройкиПодключения.Вставить("ИдентификаторИнформационнойБазыПриемника", Тело.CorrespondentCode);
	
	НастройкиПодключения.Вставить("КонечнаяТочкаКорреспондента", КонечнаяТочкаКорреспондента);
	
	НастройкиПодключения.Вставить("НастройкиXDTOКорреспондента", НастройкиXDTOКорреспондента);

	НастройкиПодключения.Вставить("Корреспондент"); // выходной параметр
	
	НастройкиПодключения.Вставить("ОбластьДанныхКорреспондента", Тело.CorrespondentZone);
	
	НачатьТранзакцию();
	Попытка
		ОбменДаннымиВМоделиСервиса.СоздатьНастройкуОбмена_3_0_1_1(НастройкиПодключения,
			Истина, , ПсевдонимЭтогоУзла);
			
		// Отправляем ответное сообщение об успешной операции.
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеНастройкаОбменаШаг1УспешноЗавершена());
			
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		
		ПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(ОбменДаннымиВМоделиСервиса.СобытиеЖурналаРегистрацииНастройкаСинхронизацииДанных(),
			УровеньЖурналаРегистрации.Ошибка, , , ПредставлениеОшибки);
		
		ОбменДаннымиВМоделиСервиса.УдалитьУзелПланаОбмена(НастройкиПодключения.Корреспондент);
		
		// Отправляем ответное сообщение об ошибке.
		НачатьТранзакцию();
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеОшибкаНастройкиОбменаШаг1());
			
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;		
		
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.ErrorDescription = ПредставлениеОшибки;
		
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		ЗафиксироватьТранзакцию();
	КонецПопытки;
	
	МодульСообщенияВМоделиСервиса.ДоставитьБыстрыеСообщения();
	
КонецПроцедуры

Процедура ЗагрузитьСообщениеОбмена(Сообщение, Отправитель) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		Возврат;
	КонецЕсли;
		
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	МодульСообщенияВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("СообщенияВМоделиСервиса");
	
	СообщениеДляСопоставленияДанных = Ложь;
	
	Если Сообщение.Установлено("AdditionalInfo") Тогда
		ДополнительныеСвойства = СериализаторXDTO.ПрочитатьXDTO(Сообщение.AdditionalInfo);
		Если ДополнительныеСвойства.Свойство("СообщениеДляСопоставленияДанных") Тогда
			СообщениеДляСопоставленияДанных = ДополнительныеСвойства.СообщениеДляСопоставленияДанных;
		КонецЕсли;
	КонецЕсли;
	
	Тело = Сообщение.Body;
	
	Если Тело.Свойства().Получить("MessageForDataMatching") <> Неопределено 
		И Тело.Установлено("MessageForDataMatching") Тогда
		СообщениеДляСопоставленияДанных = Тело.MessageForDataMatching; 
	КонецЕсли;
	
	ОтветноеСообщение = Неопределено;
	Попытка
		Корреспондент = КорреспондентОбмена(Тело.ExchangePlan, Тело.CorrespondentCode);
		
		// Загружаем сообщение обмена
		Отказ = Ложь;
		ОбменДаннымиВМоделиСервиса.ВыполнитьЗагрузкуДанных(Отказ, Корреспондент, СообщениеДляСопоставленияДанных);
		Если Отказ Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'В процессе загрузки данных из программы  ""%1"" возникли ошибки.'"),
				Строка(Корреспондент));
		КонецЕсли;
		
		// Отправляем ответное сообщение об успешной операции.
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеЗагрузкаСообщенияОбменаУспешноЗавершена());
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
	Исключение
		ПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(ОбменДаннымиВМоделиСервиса.СобытиеЖурналаРегистрацииНастройкаСинхронизацииДанных(),
			УровеньЖурналаРегистрации.Ошибка, , , ПредставлениеОшибки);
		
		// Отправляем ответное сообщение об ошибке.
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеОшибкаЗагрузкиСообщенияОбмена());
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ОтветноеСообщение.Body.ErrorDescription = ПредставлениеОшибки;
		
	КонецПопытки;
	
	Если Не ОтветноеСообщение = Неопределено Тогда
		НачатьТранзакцию();
		Попытка
			МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
		МодульСообщенияВМоделиСервиса.ДоставитьБыстрыеСообщения();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПолучитьДанныеКорреспондента(Сообщение, Отправитель)
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		Возврат;
	КонецЕсли;
		
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	МодульСообщенияВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("СообщенияВМоделиСервиса");
	
	Тело = Сообщение.Body;
	
	НачатьТранзакцию();
	Попытка
		
		ДанныеКорреспондента = ОбменДаннымиСервер.ДанныеТаблицКорреспондента(
			СериализаторXDTO.ПрочитатьXDTO(Тело.Tables), Тело.ExchangePlan);
		
		// Отправляем ответное сообщение об успешной операции
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеПолучениеДанныхКорреспондентаУспешноЗавершено());
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ОтветноеСообщение.Body.Data = Новый ХранилищеЗначения(ДанныеКорреспондента);
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		
		ПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(ОбменДаннымиВМоделиСервиса.СобытиеЖурналаРегистрацииНастройкаСинхронизацииДанных(),
			УровеньЖурналаРегистрации.Ошибка,,, ПредставлениеОшибки);
		
		// Отправляем ответное сообщение об ошибке
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеОшибкаПолученияДанныхКорреспондента());
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ОтветноеСообщение.Body.ErrorDescription = ПредставлениеОшибки;
		
		НачатьТранзакцию();
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		ЗафиксироватьТранзакцию();
	КонецПопытки;
	
	МодульСообщенияВМоделиСервиса.ДоставитьБыстрыеСообщения();
	
КонецПроцедуры

Процедура ПолучитьОбщиеДанныеУзловКорреспондента(Сообщение, Отправитель) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		Возврат;
	КонецЕсли;
		
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	МодульСообщенияВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("СообщенияВМоделиСервиса");
	
	Тело = Сообщение.Body;
	
	НачатьТранзакцию();
	Попытка
		// Отправляем ответное сообщение об успешной операции.
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеПолучениеОбщихДанныхУзловКорреспондентаУспешноЗавершено());
			
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ПредставлениеОшибки = "";
		ПараметрыИБ = ОбменДаннымиСервер.ПараметрыИнформационнойБазы(Тело.ExchangePlan, "", ПредставлениеОшибки);
		
		Результат = Новый Структура;
		Результат.Вставить("ОбщиеДанныеУзлов",            Новый Структура());
		Результат.Вставить("ПараметрыИнформационнойБазы", ПараметрыИБ);
		
		ОтветноеСообщение.Body.Data = Новый ХранилищеЗначения(Результат);
		
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		
		ПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(ОбменДаннымиВМоделиСервиса.СобытиеЖурналаРегистрацииНастройкаСинхронизацииДанных(),
			УровеньЖурналаРегистрации.Ошибка,,, ПредставлениеОшибки);
		
		// Отправляем ответное сообщение об ошибке
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеОшибкаПолученияОбщихДанныхУзловКорреспондента());
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ОтветноеСообщение.Body.ErrorDescription = ПредставлениеОшибки;
		
		НачатьТранзакцию();
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		ЗафиксироватьТранзакцию();
	КонецПопытки;
	
	МодульСообщенияВМоделиСервиса.ДоставитьБыстрыеСообщения();
	
КонецПроцедуры

Процедура ПолучитьПараметрыУчетаКорреспондента(Сообщение, Отправитель) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		Возврат;
	КонецЕсли;
		
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	МодульСообщенияВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("СообщенияВМоделиСервиса");
	
	Тело = Сообщение.Body;
	
	НачатьТранзакцию();
	Попытка
		Отказ = Ложь;
		ПредставлениеОшибки = "";
		
		ДанныеКорреспондента = Новый Структура;
		
		ПараметрыИБ = ОбменДаннымиСервер.ПараметрыИнформационнойБазы(Тело.ExchangePlan, Тело.CorrespondentCode, ПредставлениеОшибки);
		Отказ = Не ПараметрыИБ.НастройкиПараметровУчетаЗаданы;
		
		ДанныеКорреспондента.Вставить("ПараметрыИнформационнойБазы", ПараметрыИБ);
		
		ДанныеКорреспондента.Вставить("ПараметрыУчетаЗаданы", Не Отказ);
		ДанныеКорреспондента.Вставить("ПредставлениеОшибки",  ПредставлениеОшибки);
		
		// Отправляем ответное сообщение об успешной операции
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеПолучениеПараметровУчетаКорреспондентаУспешноЗавершено());
			
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.Data = Новый ХранилищеЗначения(ДанныеКорреспондента);
		
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		ОтменитьТранзакцию();
		
		ПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(ОбменДаннымиВМоделиСервиса.СобытиеЖурналаРегистрацииНастройкаСинхронизацииДанных(),
			УровеньЖурналаРегистрации.Ошибка,,, ПредставлениеОшибки);
		
		// Отправляем ответное сообщение об ошибке
		ОтветноеСообщение = МодульСообщенияВМоделиСервиса.НовоеСообщение(
			СообщенияОбменаДаннымиКонтрольИнтерфейс.СообщениеОшибкаПолученияПараметровУчетаКорреспондента());
			
		ОтветноеСообщение.Body.Zone = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		ОтветноеСообщение.Body.SessionId = Тело.SessionId;
		
		ОтветноеСообщение.Body.CorrespondentZone = Тело.CorrespondentZone;
		ОтветноеСообщение.Body.ErrorDescription = ПредставлениеОшибки;
		
		НачатьТранзакцию();
		МодульСообщенияВМоделиСервиса.ОтправитьСообщение(ОтветноеСообщение, Отправитель, Истина);
		ЗафиксироватьТранзакцию();
	КонецПопытки;
	
	МодульСообщенияВМоделиСервиса.ДоставитьБыстрыеСообщения();
	
КонецПроцедуры

Функция КорреспондентОбмена(Знач ИмяПланаОбмена, Знач Код)
	
	Результат = ПланыОбмена[ИмяПланаОбмена].НайтиПоКоду(Код);
	
	Если Не ЗначениеЗаполнено(Результат) Тогда
		СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не найден узел плана обмена; имя плана обмена %1; код узла %2.'"),
			ИмяПланаОбмена, Код);
		ВызватьИсключение СтрокаСообщения;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

#КонецОбласти
