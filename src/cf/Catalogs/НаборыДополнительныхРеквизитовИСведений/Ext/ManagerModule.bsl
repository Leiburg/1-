﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые разрешается редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив из Строка
//
Функция РеквизитыРедактируемыеВГрупповойОбработке() Экспорт
	
	РедактируемыеРеквизиты = Новый Массив;
	
	Возврат РедактируемыеРеквизиты;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

#КонецОбласти

#КонецОбласти

#КонецЕсли

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	Поля.Добавить("ИмяПредопределенногоНабора");
	Поля.Добавить("Наименование");
	Поля.Добавить("Ссылка");
	Поля.Добавить("Родитель");
	
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	Если ТекущийЯзык() = Метаданные.ОсновнойЯзык Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Данные.Родитель) Тогда
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
			МодульМультиязычностьКлиентСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьКлиентСервер");
			МодульМультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка);
		КонецЕсли;
#Иначе
		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
			МодульМультиязычностьКлиентСервер = ОбщегоНазначенияКлиент.ОбщийМодуль("МультиязычностьКлиентСервер");
			МодульМультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка);
		КонецЕсли;
#КонецЕсли
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Данные.ИмяПредопределенногоНабора) Тогда
		ИмяНабора = Данные.ИмяПредопределенногоНабора;
	Иначе
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
		ИмяНабора = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Данные.Ссылка, "ИмяПредопределенныхДанных");
#Иначе
		ИмяНабора = "";
#КонецЕсли
	КонецЕсли;
	Представление = ПредставлениеНабораВерхнегоУровня(ИмяНабора, Данные);
	
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

#КонецОбласти

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Обновляет состав наименований предопределенных наборов в
// параметрах дополнительных реквизитов и сведений.
//
// Параметры:
//  ЕстьИзменения - Булево - возвращаемое значение. Если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьСоставНаименованийПредопределенныхНаборов(ЕстьИзменения = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПредопределенныеНаборы = ПредопределенныеНаборыСвойств();
	
	НачатьТранзакцию();
	Попытка
		ЕстьТекущиеИзменения = Ложь;
		СтароеЗначение = Неопределено;
		
		СтандартныеПодсистемыСервер.ОбновитьПараметрРаботыПрограммы(
			"СтандартныеПодсистемы.Свойства.ПредопределенныеНаборыДополнительныхРеквизитовИСведений",
			ПредопределенныеНаборы, ЕстьТекущиеИзменения, СтароеЗначение);
		
		СтандартныеПодсистемыСервер.ДобавитьИзмененияПараметраРаботыПрограммы(
			"СтандартныеПодсистемы.Свойства.ПредопределенныеНаборыДополнительныхРеквизитовИСведений",
			?(ЕстьТекущиеИзменения,
			  Новый ФиксированнаяСтруктура("ЕстьИзменения", Истина),
			  Новый ФиксированнаяСтруктура()) );
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Если ЕстьТекущиеИзменения Тогда
		ЕстьИзменения = Истина;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьНаборыСвойствДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ПредопределенныеНаборыСвойств = УправлениеСвойствамиПовтИсп.ПредопределенныеНаборыСвойств();
	ПроблемныхОбъектов = 0;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Наборы.Ссылка КАК Ссылка,
		|	Наборы.ИмяПредопределенныхДанных КАК ИмяПредопределенныхДанных,
		|	Наборы.ДополнительныеРеквизиты.(
		|		Свойство КАК Свойство
		|	) КАК ДополнительныеРеквизиты,
		|	Наборы.ДополнительныеСведения.(
		|		Свойство КАК Свойство
		|	) КАК ДополнительныеСведения,
		|	Наборы.Родитель КАК Родитель,
		|	Наборы.ЭтоГруппа КАК ЭтоГруппа
		|ИЗ
		|	Справочник.НаборыДополнительныхРеквизитовИСведений КАК Наборы
		|ГДЕ
		|	Наборы.Предопределенный = ИСТИНА";
	Результат = Запрос.Выполнить().Выгрузить();
	
	Для Каждого ОбновляемыйНабор Из Результат Цикл
		
		НачатьТранзакцию();
		Попытка
			Если Не ЗначениеЗаполнено(ОбновляемыйНабор.ИмяПредопределенныхДанных) Тогда
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			Если Не СтрНачинаетсяС(ОбновляемыйНабор.ИмяПредопределенныхДанных, "Удалить") Тогда
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			Если ОбновляемыйНабор.ДополнительныеРеквизиты.Количество() = 0
				И ОбновляемыйНабор.ДополнительныеСведения.Количество() = 0 Тогда
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			ДлинаПрефикса = СтрДлина("Удалить");
			ИмяНабора = Сред(ОбновляемыйНабор.ИмяПредопределенныхДанных, ДлинаПрефикса + 1, СтрДлина(ОбновляемыйНабор.ИмяПредопределенныхДанных) - ДлинаПрефикса);
			ОписаниеНовогоНабора = ПредопределенныеНаборыСвойств.Получить(ИмяНабора); // см. Справочники.НаборыДополнительныхРеквизитовИСведений.СвойстваНабора
			Если ОписаниеНовогоНабора = Неопределено Тогда
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			НовыйНабор = ОписаниеНовогоНабора.Ссылка;
			
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить("Справочник.НаборыДополнительныхРеквизитовИСведений");
			ЭлементБлокировки.УстановитьЗначение("Ссылка", НовыйНабор);
			Блокировка.Заблокировать();
			
			// Заполнение нового набора.
			НовыйНаборОбъект = НовыйНабор.ПолучитьОбъект();
			Если ОбновляемыйНабор.ЭтоГруппа <> НовыйНаборОбъект.ЭтоГруппа Тогда
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			Для Каждого СтрокаРеквизит Из ОбновляемыйНабор.ДополнительныеРеквизиты Цикл
				Если Не ЗначениеЗаполнено(СтрокаРеквизит.Свойство) Тогда
					Продолжить;
				КонецЕсли;
				НоваяСтрокаРеквизиты = НовыйНаборОбъект.ДополнительныеРеквизиты.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрокаРеквизиты, СтрокаРеквизит);
				НоваяСтрокаРеквизиты.ИмяПредопределенногоНабора = НовыйНаборОбъект.ИмяПредопределенногоНабора;
				
				// Обновление набора свойств в зависимостях дополнительного реквизита.
				Свойство = НоваяСтрокаРеквизиты.Свойство;
				Блокировка = Новый БлокировкаДанных;
				ЭлементБлокировки = Блокировка.Добавить("ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения");
				ЭлементБлокировки.УстановитьЗначение("Ссылка", Свойство);
				Блокировка.Заблокировать();
				
				СвойствоОбъект = Свойство.ПолучитьОбъект();
				Если СвойствоОбъект = Неопределено Тогда
					Продолжить;
				КонецЕсли;
				
				Если СвойствоОбъект.НаборСвойств = ОбновляемыйНабор.Ссылка Тогда
					СвойствоОбъект.НаборСвойств = НовыйНабор;
				КонецЕсли;
				
				Для Каждого Зависимость Из СвойствоОбъект.ЗависимостиДополнительныхРеквизитов Цикл
					Если Зависимость.НаборСвойств = ОбновляемыйНабор.Ссылка Тогда
						Зависимость.НаборСвойств = НовыйНабор;
					КонецЕсли;
				КонецЦикла;
				ОбновлениеИнформационнойБазы.ЗаписатьОбъект(СвойствоОбъект);
			КонецЦикла;
			Для Каждого СтрокаСведение Из ОбновляемыйНабор.ДополнительныеСведения Цикл
				НоваяСтрокаСведения = НовыйНаборОбъект.ДополнительныеСведения.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрокаСведения, СтрокаСведение);
				НоваяСтрокаСведения.ИмяПредопределенногоНабора = НовыйНаборОбъект.ИмяПредопределенногоНабора;
			КонецЦикла;
			
			Если Не ОбновляемыйНабор.ЭтоГруппа Тогда
				КоличествоРеквизитов = Формат(НовыйНаборОбъект.ДополнительныеРеквизиты.НайтиСтроки(
					Новый Структура("ПометкаУдаления", Ложь)).Количество(), "ЧГ=");
				КоличествоСведений   = Формат(НовыйНаборОбъект.ДополнительныеСведения.НайтиСтроки(
					Новый Структура("ПометкаУдаления", Ложь)).Количество(), "ЧГ=");
				
				НовыйНаборОбъект.КоличествоРеквизитов = КоличествоРеквизитов;
				НовыйНаборОбъект.КоличествоСведений   = КоличествоСведений;
			КонецЕсли;
			
			ОбновлениеИнформационнойБазы.ЗаписатьОбъект(НовыйНаборОбъект);
			
			// Очистка старого набора.
			УстаревшийНаборОбъект = ОбновляемыйНабор.Ссылка.ПолучитьОбъект();
			УстаревшийНаборОбъект.ДополнительныеРеквизиты.Очистить();
			УстаревшийНаборОбъект.ДополнительныеСведения.Очистить();
			УстаревшийНаборОбъект.Используется = Ложь;
			
			ОбновлениеИнформационнойБазы.ЗаписатьОбъект(УстаревшийНаборОбъект);
			
			Если ОбновляемыйНабор.ЭтоГруппа Тогда
				Запрос = Новый Запрос;
				Запрос.УстановитьПараметр("Родитель", ОбновляемыйНабор.Ссылка);
				Запрос.Текст = 
					"ВЫБРАТЬ
					|	НаборыДополнительныхРеквизитовИСведений.Ссылка КАК Ссылка
					|ИЗ
					|	Справочник.НаборыДополнительныхРеквизитовИСведений КАК НаборыДополнительныхРеквизитовИСведений
					|ГДЕ
					|	НаборыДополнительныхРеквизитовИСведений.Родитель = &Родитель
					|	И НаборыДополнительныхРеквизитовИСведений.Предопределенный = ЛОЖЬ";
				ПереносимыеНаборы = Запрос.Выполнить().Выгрузить();
				Для Каждого Строка Из ПереносимыеНаборы Цикл
					НаборОбъект = Строка.Ссылка.ПолучитьОбъект();
					НаборОбъект.Родитель = НовыйНабор;
					ОбновлениеИнформационнойБазы.ЗаписатьОбъект(НаборОбъект);
				КонецЦикла;
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать набор свойств %1 по причине:
					|%2'"), 
					ОбновляемыйНабор.Ссылка, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
				Метаданные.Справочники.НаборыДополнительныхРеквизитовИСведений, ОбновляемыйНабор.Ссылка, ТекстСообщения);
		КонецПопытки;
		
	КонецЦикла;
	
	Если ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = НСтр("ru = 'Процедура ОбработатьНаборыСвойствДляПереходаНаНовуюВерсию завершилась с ошибкой. Не все наборы свойств удалось обновить.'");
		ВызватьИсключение ТекстСообщения;
	КонецЕсли;
	
	Параметры.ОбработкаЗавершена = Истина;
	
КонецПроцедуры

// Начальное заполнение наборов

// Смотри также ОбновлениеИнформационнойБазыПереопределяемый.ПриНастройкеНачальногоЗаполненияЭлементов
// 
// Параметры:
//  Настройки - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНастройкеНачальногоЗаполненияЭлементов.Настройки
//
Процедура ПриНастройкеНачальногоЗаполненияЭлементов(Настройки) Экспорт
	
	Настройки.ПриНачальномЗаполненииЭлемента = Ложь;
	
	УправлениеСвойствамиПереопределяемый.ПриНастройкеНачальногоЗаполненияЭлементов(Настройки);
	
	Настройки.ИмяКлючевогоРеквизита          = "Ссылка";
	
КонецПроцедуры

// Смотри также ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов
// 
// Параметры:
//   КодыЯзыков - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов.КодыЯзыков
//   Элементы - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов.Элементы
//   ТабличныеЧасти - см. ОбновлениеИнформационнойБазыПереопределяемый.ПриНачальномЗаполненииЭлементов.ТабличныеЧасти
//
Процедура ПриНачальномЗаполненииЭлементов(КодыЯзыков, Элементы, ТабличныеЧасти) Экспорт
	
	УправлениеСвойствамиПереопределяемый.ПриНачальномЗаполненииЭлементов(КодыЯзыков, Элементы, ТабличныеЧасти);
	
КонецПроцедуры


// Смотри также ОбновлениеИнформационнойБазыПереопределяемый.ПриНастройкеНачальногоЗаполненияЭлемента
//
// Параметры:
//  Объект                  - СправочникОбъект.ВидыКонтактнойИнформации - заполняемый объект.
//  Данные                  - СтрокаТаблицыЗначений - данные заполнения объекта.
//  ДополнительныеПараметры - Структура:
//   * ПредопределенныеДанные - ТаблицаЗначений - данные заполненные в процедуре ПриНачальномЗаполненииЭлементов.
//
Процедура ПриНачальномЗаполненииЭлемента(Объект, Данные, ДополнительныеПараметры) Экспорт
	
	УправлениеСвойствамиПереопределяемый.ПриНачальномЗаполненииЭлемента(Объект, Данные, ДополнительныеПараметры);
	
КонецПроцедуры

//



#КонецОбласти

#КонецЕсли

#Область СлужебныеПроцедурыИФункции

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Функция ПредопределенныеНаборыСвойств() Экспорт
	
	ДеревоНаборов = Новый ДеревоЗначений;
	ДеревоНаборов.Колонки.Добавить("Имя");
	ДеревоНаборов.Колонки.Добавить("ЭтоГруппа", Новый ОписаниеТипов("Булево"));
	ДеревоНаборов.Колонки.Добавить("Используется");
	ДеревоНаборов.Колонки.Добавить("Идентификатор");
	ИнтеграцияПодсистемБСП.ПриПолученииПредопределенныхНаборовСвойств(ДеревоНаборов);
	УправлениеСвойствамиПереопределяемый.ПриПолученииПредопределенныхНаборовСвойств(ДеревоНаборов);
	
	НаименованияНаборовСвойств = УправлениеСвойствамиСлужебный.НаименованияНаборовСвойств();
	Наименования = НаименованияНаборовСвойств[ТекущийЯзык().КодЯзыка];
	
	НаборыСвойств = Новый Соответствие;
	Для Каждого Набор Из ДеревоНаборов.Строки Цикл
		СвойстваНабора = СвойстваНабора(НаборыСвойств, Набор);
		Для Каждого ДочернийНабор Из Набор.Строки Цикл
			СвойстваДочернегоНабора = СвойстваНабора(НаборыСвойств, ДочернийНабор, СвойстваНабора.Ссылка, Наименования);
			СвойстваНабора.ДочерниеНаборы.Вставить(ДочернийНабор.Имя, СвойстваДочернегоНабора);
		КонецЦикла;
		СвойстваНабора.ДочерниеНаборы = Новый ФиксированноеСоответствие(СвойстваНабора.ДочерниеНаборы);
		НаборыСвойств[СвойстваНабора.Имя] = Новый ФиксированнаяСтруктура(НаборыСвойств[СвойстваНабора.Имя]);
		НаборыСвойств[СвойстваНабора.Ссылка] = Новый ФиксированнаяСтруктура(НаборыСвойств[СвойстваНабора.Ссылка]);
	КонецЦикла;
	
	ПредопределенныеДанные = УправлениеСвойствамиСлужебный.ПредопределенныеНаборыСвойств();
	
	НаименованиеНаЯзыкеПользователя = "Наименование" + "_" + ТекущийЯзык().КодЯзыка;
	ЕстьЯзыковаяКолонка = ПредопределенныеДанные.Колонки.Найти(НаименованиеНаЯзыкеПользователя) <> Неопределено;
	
	Для Каждого Набор Из ПредопределенныеДанные Цикл
		
		Если ЕстьЯзыковаяКолонка Тогда
			Наименование = ?(ЕстьЯзыковаяКолонка, Набор[НаименованиеНаЯзыкеПользователя], Набор["Наименование"]);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Набор.Родитель) Тогда
			Родитель = СсылкаНаРодителя(Набор.Родитель);
			
			СвойстваНабора = НаборыСвойств.Получить(Родитель);
			СвойстваДочернегоНабора = СвойстваНабораНачальногоЗаполнения(НаборыСвойств, Набор, Родитель, Наименование);
			СвойстваНабора.ДочерниеНаборы.Вставить(Набор.ИмяПредопределенногоНабора, СвойстваДочернегоНабора);
			
		Иначе
			СвойстваНабора = СвойстваНабораНачальногоЗаполнения(НаборыСвойств, Набор, Набор.Родитель, Наименование);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(НаборыСвойств);
	
КонецФункции

// Только для внутреннего использования.
// 
// Возвращаемое значение:
//  Структура:
//     * Имя            - Строка
//     * ЭтоГруппа      - Булево
//     * Используется   - Булево
//     * Ссылка         - СправочникСсылка.НаборыДополнительныхРеквизитовИСведений
//     * Родитель       - СправочникСсылка.НаборыДополнительныхРеквизитовИСведений
//     * ДочерниеНаборы - Соответствие из КлючИЗначение:
//        ** Ключ - Строка
//        ** Значение - см. СвойстваНабора
//     * Наименование   - Строка
//
Функция СвойстваНабора(НаборыСвойств, Набор, Родитель = Неопределено, Наименования = Неопределено) Экспорт
	
	ЗаголовокОшибки =
		НСтр("ru = 'Ошибка в процедуре ПриСозданииПредопределенныхНаборовСвойств
		           |общего модуля УправлениеСвойствамиПереопределяемый.'")
		+ Символы.ПС
		+ Символы.ПС;
	
	Если Не ЗначениеЗаполнено(Набор.Имя) Тогда
		ВызватьИсключение ЗаголовокОшибки + НСтр("ru = 'Имя набора свойств не заполнено.'");
	КонецЕсли;
	
	Если НаборыСвойств.Получить(Набор.Имя) <> Неопределено Тогда
		ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Имя набора свойств ""%1"" уже определено.'"),
			Набор.Имя);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Набор.Идентификатор) Тогда
		ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Идентификатор набора свойств ""%1"" не заполнен.'"),
			Набор.Имя);
	КонецЕсли;
	
	Если Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		НаборСсылка = Набор.Идентификатор;
	Иначе
		НаборСсылка = ПолучитьСсылку(Набор.Идентификатор);
	КонецЕсли;
	
	Если НаборыСвойств.Получить(НаборСсылка) <> Неопределено Тогда
		СвойстваНабора = НаборыСвойств.Получить(НаборСсылка);
		ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Идентификатор ""%1"" набора свойств
			           |""%2"" уже используется для набора ""%3"".'"),
			Набор.Идентификатор, Набор.Имя, СвойстваНабора.Имя);
	КонецЕсли;
	
	СвойстваНабора = НовыеСвойстваНабора();
	СвойстваНабора.Имя            = Набор.Имя;
	СвойстваНабора.ЭтоГруппа      = Набор.ЭтоГруппа;
	СвойстваНабора.Используется   = Набор.Используется;
	СвойстваНабора.Ссылка         = НаборСсылка;
	СвойстваНабора.Родитель       = Родитель;
	СвойстваНабора.ДочерниеНаборы = ?(Родитель = Неопределено, Новый Соответствие, Неопределено);
	
	Если Наименования = Неопределено Тогда
		СвойстваНабора.Наименование = ПредставлениеНабораВерхнегоУровня(Набор.Имя);
	Иначе
		СвойстваНабора.Наименование = Наименования[Набор.Имя];
	КонецЕсли;
	
	Если Родитель <> Неопределено Тогда
		СвойстваНабора = Новый ФиксированнаяСтруктура(СвойстваНабора);
	КонецЕсли;
	НаборыСвойств.Вставить(СвойстваНабора.Имя,    СвойстваНабора);
	НаборыСвойств.Вставить(СвойстваНабора.Ссылка, СвойстваНабора);
	
	Возврат СвойстваНабора;
	
КонецФункции

// Только для внутреннего использования.
// 
// Возвращаемое значение:
//  Структура:
//     * Имя            - Строка
//     * ЭтоГруппа      - Булево
//     * Используется   - Булево
//     * Ссылка         - СправочникСсылка.НаборыДополнительныхРеквизитовИСведений
//     * Родитель       - СправочникСсылка.НаборыДополнительныхРеквизитовИСведений
//     * ДочерниеНаборы - Соответствие из КлючИЗначение:
//        ** Ключ - Строка
//        ** Значение - см. СвойстваНабора
//     * Наименование   - Строка
//
Функция СвойстваНабораНачальногоЗаполнения(НаборыСвойств, Набор, Родитель = Неопределено, Наименование = Неопределено)
	
	ЗаголовокОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Ошибка в процедуре %1 общего модуля %2.'")
		+ Символы.ПС + Символы.ПС, "ПриНачальномЗаполненииЭлементов", "УправлениеСвойствамиПереопределяемый");
	
	Если Не ЗначениеЗаполнено(Набор.ИмяПредопределенногоНабора) Тогда
		ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 набора свойств не заполнено.'"), "ИмяПредопределенногоНабора");
	КонецЕсли;
	
	Если НаборыСвойств.Получить(Набор.ИмяПредопределенногоНабора) <> Неопределено Тогда
		ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 набора свойств ""%2"" уже определено.'"), 
			"ИмяПредопределенногоНабора", Набор.ИмяПредопределенногоНабора);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Набор.Ссылка) Тогда
		ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ссылка набора свойств ""%1"" не заполнен.'"),
			Набор.ИмяПредопределенногоНабора);
	КонецЕсли;
	
	НаборСсылка = Набор.Ссылка;
	
	Если НаборыСвойств.Получить(НаборСсылка) <> Неопределено Тогда
		СвойстваНабора = НаборыСвойств.Получить(НаборСсылка);
		ВызватьИсключение ЗаголовокОшибки + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ссылка ""%1"" набора свойств
			           |""%2"" уже используется для набора ""%3"".'"),
			Набор.Ссылка, Набор.ИмяПредопределенногоНабора, СвойстваНабора.ИмяПредопределенногоНабора);
	КонецЕсли;
	
	Родитель = СсылкаНаРодителя(Родитель);
	
	СвойстваНабора = НовыеСвойстваНабора();
	СвойстваНабора.Имя = Набор.ИмяПредопределенногоНабора;
	СвойстваНабора.ЭтоГруппа = Набор.ЭтоГруппа;
	СвойстваНабора.Используется = Набор.Используется;
	СвойстваНабора.Ссылка = НаборСсылка;
	СвойстваНабора.Родитель = Родитель;
	СвойстваНабора.ДочерниеНаборы = ?(Родитель = Неопределено, Новый Соответствие, Неопределено);

	Если ЗначениеЗаполнено(Наименование) Тогда
		СвойстваНабора.Вставить("Наименование", Наименование);
	Иначе
		СвойстваНабора.Вставить("Наименование", Набор["Наименование"]); 
	КонецЕсли;
	
	СвойстваНабора = Новый ФиксированнаяСтруктура(СвойстваНабора);
	НаборыСвойств.Вставить(СвойстваНабора.Имя, СвойстваНабора);
	НаборыСвойств.Вставить(СвойстваНабора.Ссылка, СвойстваНабора);
	
	Возврат СвойстваНабора;
	
КонецФункции

// Возвращаемое значение:
//  Структура:
//   * Имя - Строка
//   * ЭтоГруппа - Булево
//   * Используется - Неопределено
//   * Ссылка - Неопределено
//   * Родитель - Неопределено
//   * ДочерниеНаборы - Неопределено
//   * Наименование - Строка
//
Функция НовыеСвойстваНабора()
	
	СвойстваНабора = Новый Структура;
	СвойстваНабора.Вставить("Имя", "");
	СвойстваНабора.Вставить("ЭтоГруппа", Ложь);
	СвойстваНабора.Вставить("Используется", Неопределено);
	СвойстваНабора.Вставить("Ссылка", Неопределено);
	СвойстваНабора.Вставить("Родитель", Неопределено);
	СвойстваНабора.Вставить("ДочерниеНаборы", Неопределено);
	СвойстваНабора.Вставить("Наименование", "");
	
	Возврат СвойстваНабора;

КонецФункции

Функция СсылкаНаРодителя(Родитель)
	
	Если ЗначениеЗаполнено(Родитель) Тогда
		
		Если Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
			Возврат Новый УникальныйИдентификатор(Родитель);
		КонецЕсли;
			
			Если ТипЗнч(Родитель) = Тип("Строка") Тогда
				Родитель = ПолучитьСсылку(Новый УникальныйИдентификатор(Родитель));
			ИначеЕсли ТипЗнч(Родитель) = Тип("УникальныйИдентификатор") Тогда
				Родитель = ПолучитьСсылку(Родитель);
			КонецЕсли;
		
	КонецЕсли;
	
	Возврат Родитель;
	
КонецФункции

#КонецЕсли

// АПК:361-выкл нет обращения к серверному коду.
Функция ПредставлениеНабораВерхнегоУровня(ИмяПредопределенного, СвойстваНабора = Неопределено)
	
	Представление = "";
	Позиция = СтрНайти(ИмяПредопределенного, "_");
	ПерваяЧастьИмени =  Лев(ИмяПредопределенного, Позиция - 1);
	ВтораяЧастьИмени = Прав(ИмяПредопределенного, СтрДлина(ИмяПредопределенного) - Позиция);
	
	ПолноеИмя = ПерваяЧастьИмени + "." + ВтораяЧастьИмени;
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ПолноеИмя);
	Если ОбъектМетаданных = Неопределено Тогда
		Возврат Представление;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОбъектМетаданных.ПредставлениеСписка) Тогда
		Представление = ОбъектМетаданных.ПредставлениеСписка;
	ИначеЕсли ЗначениеЗаполнено(ОбъектМетаданных.Синоним) Тогда
		Представление = ОбъектМетаданных.Синоним;
	ИначеЕсли СвойстваНабора <> Неопределено Тогда
		Представление = СвойстваНабора.Наименование;
	КонецЕсли;
	
	Возврат Представление;
	
КонецФункции

#КонецОбласти