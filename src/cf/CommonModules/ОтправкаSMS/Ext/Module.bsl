﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Отправляет SMS через настроенного поставщика услуги, возвращает идентификатор сообщения.
//
// Параметры:
//  НомераПолучателей  - Массив - массив строк номеров получателей в формате +7ХХХХХХХХХХ;
//  Текст              - Строка - текст сообщения, максимальная длина у операторов может быть разной;
//  ИмяОтправителя     - Строка - имя отправителя, которое будет отображаться вместо номера у получателей;
//  ПеревестиВТранслит - Булево - Истина, если требуется переводить текст сообщения в транслит перед отправкой.
//
// Возвращаемое значение:
//  Структура - результат отправки:
//    * ОтправленныеСообщения - Массив - массив структур:
//      ** НомерПолучателя - Строка - номер получателя SMS.
//      ** ИдентификаторСообщения - Строка - идентификатор SMS, присвоенный провайдером для отслеживания доставки.
//    * ОписаниеОшибки - Строка - пользовательское представление ошибки, если пустая строка, то ошибки нет.
//
Функция ОтправитьSMS(НомераПолучателей, Знач Текст, ИмяОтправителя = Неопределено, ПеревестиВТранслит = Ложь) Экспорт
	
	ПроверитьПрава();
	
	Результат = Новый Структура("ОтправленныеСообщения,ОписаниеОшибки", Новый Массив, "");
	
	Если ПеревестиВТранслит Тогда
		Текст = СтроковыеФункцииКлиентСервер.СтрокаЛатиницей(Текст);
	КонецЕсли;
	
	Если Не НастройкаОтправкиSMSВыполнена() Тогда
		Результат.ОписаниеОшибки = НСтр("ru = 'Неверно заданы настройки провайдера для отправки SMS.'");
		Возврат Результат;
	КонецЕсли;
	
	НастройкиОтправкиSMS = ОтправкаSMSПовтИсп.НастройкиОтправкиSMS();
	Если ИмяОтправителя = Неопределено Тогда
		ИмяОтправителя = НастройкиОтправкиSMS.ИмяОтправителя;
	КонецЕсли;
	
	ПровайдерыSMS = Новый Соответствие;
	Для Каждого Провайдер Из Метаданные.Перечисления.ПровайдерыSMS.ЗначенияПеречисления Цикл
		ПровайдерыSMS.Вставить(Перечисления.ПровайдерыSMS[Провайдер.Имя], Провайдер.Имя);
	КонецЦикла;
	
	МодульОтправкаSMSЧерезПровайдера = МодульОтправкаSMSЧерезПровайдера(НастройкиОтправкиSMS.Провайдер);
	Если МодульОтправкаSMSЧерезПровайдера <> Неопределено Тогда
		Результат = МодульОтправкаSMSЧерезПровайдера.ОтправитьSMS(НомераПолучателей, Текст, ИмяОтправителя,
			НастройкиОтправкиSMS.Логин, НастройкиОтправкиSMS.Пароль);
	Иначе
		ПараметрыОтправки = Новый Структура;
		ПараметрыОтправки.Вставить("НомераПолучателей", НомераПолучателей);
		ПараметрыОтправки.Вставить("Текст", Текст);
		ПараметрыОтправки.Вставить("ИмяОтправителя", ИмяОтправителя);
		ПараметрыОтправки.Вставить("Логин", НастройкиОтправкиSMS.Логин);
		ПараметрыОтправки.Вставить("Пароль", НастройкиОтправкиSMS.Пароль);
		ПараметрыОтправки.Вставить("Провайдер", НастройкиОтправкиSMS.Провайдер);
		
		ОтправкаSMSПереопределяемый.ОтправитьSMS(ПараметрыОтправки, Результат);
		
		ОбщегоНазначенияКлиентСервер.ПроверитьПараметр("ОтправкаSMSПереопределяемый.ОтправитьSMS", "Результат", Результат,
			Тип("Структура"), Новый Структура("ОтправленныеСообщения,ОписаниеОшибки", Тип("Массив"), Тип("Строка")));
			
		Если Не ЗначениеЗаполнено(Результат.ОписаниеОшибки) И Не ЗначениеЗаполнено(Результат.ОтправленныеСообщения) Тогда
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Ошибка при выходе из процедуры ОтправкаSMSПереопределяемый.ОтправитьSMS:
					|Не заполнены выходные параметры ОписаниеОшибки и ОтправленныеСообщения (провайдер: %1).
					|Ожидается заполнение по меньшей мере одного из этих параметров.'", ОбщегоНазначения.КодОсновногоЯзыка()),
					НастройкиОтправкиSMS.Провайдер);
		КонецЕсли;
		
		Если Результат.ОтправленныеСообщения.Количество() > 0 Тогда
			ОбщегоНазначенияКлиентСервер.Проверить(
				ТипЗнч(Результат.ОтправленныеСообщения[0]) = Тип("Структура"),
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Неверный тип значения в коллекции Результат.ОтправленныеСообщения:
						|ожидается тип ""Структура"", передан тип ""%1""'"),
						ТипЗнч(Результат.ОтправленныеСообщения[0])),
				"ОтправкаSMSПереопределяемый.ОтправитьSMS");
			Для Индекс = 0 По Результат.ОтправленныеСообщения.Количество() - 1 Цикл
				ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
					"ОтправкаSMSПереопределяемый.ОтправитьSMS",
					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("Результат.ОтправленныеСообщения[%1]", Формат(Индекс, "ЧН=; ЧГ=0")),
					Результат.ОтправленныеСообщения[Индекс],
					Тип("Структура"),
					Новый Структура("НомерПолучателя,ИдентификаторСообщения", Тип("Строка"), Тип("Строка")));
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Запрашивает статус доставки сообщения у поставщика услуг.
//
// Параметры:
//  ИдентификаторСообщения - Строка - идентификатор, присвоенный SMS при отправке;
//
// Возвращаемое значение:
//  Строка - статус доставки сообщения, который вернул поставщик услуг:
//           "НеОтправлялось" - сообщение еще не было обработано поставщиком услуг (в очереди);
//           "Отправляется"   - сообщение стоит в очереди на отправку у провайдера;
//           "Отправлено"     - сообщение отправлено, ожидается подтверждение о доставке;
//           "НеОтправлено"   - сообщение не отправлено (недостаточно средств на счете, перегружена сеть оператора);
//           "Доставлено"     - сообщение доставлено адресату;
//           "НеДоставлено"   - сообщение не удалось доставить (абонент недоступен, время ожидания подтверждения
//                              доставки от абонента истекло);
//           "Ошибка"         - не удалось получить статус у поставщика услуг (статус неизвестен).
//
Функция СтатусДоставки(Знач ИдентификаторСообщения) Экспорт
	
	ПроверитьПрава();
	
	Если ПустаяСтрока(ИдентификаторСообщения) Тогда
		Возврат "НеОтправлялось";
	КонецЕсли;
	
	Результат = ОтправкаSMSПовтИсп.СтатусДоставки(ИдентификаторСообщения);
	
	Возврат Результат;
	
КонецФункции

// Проверяет правильность сохраненных настроек отправки SMS.
//
// Возвращаемое значение:
//  Булево - Истина, если отправка SMS уже настроена.
Функция НастройкаОтправкиSMSВыполнена() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	НастройкиОтправкиSMS = ОтправкаSMSПовтИсп.НастройкиОтправкиSMS();
	УстановитьПривилегированныйРежим(Ложь);
	
	Если ЗначениеЗаполнено(НастройкиОтправкиSMS.Провайдер) Тогда
		Отказ = ПустаяСтрока(НастройкиОтправкиSMS.Логин) Или ПустаяСтрока(НастройкиОтправкиSMS.Пароль);
		ОтправкаSMSПереопределяемый.ПриПроверкеНастроекОтправкиSMS(НастройкиОтправкиSMS, Отказ);
		Возврат Не Отказ;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// Проверяет возможность отправки SMS для текущего пользователя.
// 
// Возвращаемое значение:
//  Булево - Истина, если отправка SMS настроена и у текущего пользователя достаточно прав для отправки SMS.
//
Функция ДоступнаОтправкаSMS() Экспорт
	Возврат ПравоДоступа("Просмотр", Метаданные.ОбщиеФормы.ОтправкаSMS) И НастройкаОтправкиSMSВыполнена() Или Пользователи.ЭтоПолноправныйПользователь();
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиента.
Процедура ПриДобавленииПараметровРаботыКлиента(Параметры) Экспорт
	Параметры.Вставить("ДоступнаОтправкаSMS", ДоступнаОтправкаSMS());
КонецПроцедуры

// См. РаботаВБезопасномРежимеПереопределяемый.ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам.
Процедура ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(ЗапросыРазрешений) Экспорт
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Для Каждого МодульПровайдера Из МодулиПровайдеров() Цикл
		МодульОтправкаSMSЧерезПровайдера = МодульПровайдера.Значение;
		ЗапросыРазрешений.Добавить(
			МодульРаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов(МодульОтправкаSMSЧерезПровайдера.Разрешения()));
	КонецЦикла;
	
	ЗапросыРазрешений.Добавить(
		МодульРаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов(ДополнительныеРазрешения()));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДополнительныеРазрешения()
	Разрешения = Новый Массив;
	ОтправкаSMSПереопределяемый.ПриПолученииРазрешений(Разрешения);
	
	Возврат Разрешения;
КонецФункции

Процедура ПроверитьПрава() Экспорт
	Если Не ПравоДоступа("Просмотр", Метаданные.ОбщиеФормы.ОтправкаSMS) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для выполнения операции.'");
	КонецЕсли;
КонецПроцедуры

Функция МодульОтправкаSMSЧерезПровайдера(Провайдер) Экспорт
	Возврат МодулиПровайдеров()[Провайдер];
КонецФункции

Функция МодулиПровайдеров()
	Результат = Новый Соответствие;
	
	Для Каждого ОбъектМетаданных Из Метаданные.Перечисления.ПровайдерыSMS.ЗначенияПеречисления Цикл
		ИмяМодуля = "ОтправкаSMSЧерез" + ОбъектМетаданных.Имя;
		Если Метаданные.ОбщиеМодули.Найти(ИмяМодуля) <> Неопределено Тогда
			Результат.Вставить(Перечисления.ПровайдерыSMS[ОбъектМетаданных.Имя], ОбщегоНазначения.ОбщийМодуль(ИмяМодуля));
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

Функция ПодготовитьHTTPЗапрос(АдресРесурса, ПараметрыЗапроса) Экспорт
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	
	Если ТипЗнч(ПараметрыЗапроса) = Тип("Строка") Тогда
		СтрокаПараметров = ПараметрыЗапроса;
	Иначе
		СписокПараметров = Новый Массив;
		Для Каждого Параметр Из ПараметрыЗапроса Цикл
			СписокПараметров.Добавить(Параметр.Ключ + "=" + КодироватьСтроку(Параметр.Значение, СпособКодированияСтроки.КодировкаURL));
		КонецЦикла;
		СтрокаПараметров = СтрСоединить(СписокПараметров, "&");
	КонецЕсли;
	
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса, Заголовки);
	HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаПараметров);
	
	Возврат HTTPЗапрос;

КонецФункции

#КонецОбласти
