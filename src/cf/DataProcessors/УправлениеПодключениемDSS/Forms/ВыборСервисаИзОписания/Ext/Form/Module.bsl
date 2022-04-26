﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ПрограммноеЗакрытие;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОписаниеСервисаОбнаружения = Параметры.ОписаниеСервисаОбнаружения;
	Если ОписаниеСервисаОбнаружения <> Неопределено Тогда
		ЗаполнитьСписки(ОписаниеСервисаОбнаружения);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СервисКриптографииDSSСлужебныйКлиент.ПриОткрытииФормы(ЭтотОбъект, ПрограммноеЗакрытие);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если СервисКриптографииDSSСлужебныйКлиент.ПередЗакрытиемФормы(
			ЭтотОбъект,
			Отказ,
			ПрограммноеЗакрытие,
			ЗавершениеРаботы) Тогда
		ЗакрытьФорму();
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Отмена(Команда)
	
	ЗакрытьФорму();
	
КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	
	Результат = Новый Структура;
	Результат.Вставить("АдресЦИ", АдресСервисаЦентраИдентификации);
	Результат.Вставить("АдресСЭП", АдресСервисаЭлектроннойПодписи);
	
	ПараметрыЗакрытия = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию();
	ПараметрыЗакрытия.Вставить("Результат", Результат);
	
	ЗакрытьФорму(ПараметрыЗакрытия);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗакрытьФорму(ПараметрыЗакрытия = Неопределено)
	
	ПрограммноеЗакрытие = Истина;
	
	Если ПараметрыЗакрытия = Неопределено Тогда
		ПараметрыЗакрытия = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию(Ложь, "ОтказПользователя");
	КонецЕсли;
	
	Закрыть(ПараметрыЗакрытия);
	
КонецПроцедуры	

// Разбор массива описаний
//
// Параметры:
//  ОписаниеСервисаОбнаружения - Структура:
//    * СервисыЦИ - Массив из Структура:
//      ** АдресСервиса - Строка
//      ** Заголовок	- Строка
//    * СервисыСЭП - Массив из Структура:
//      ** АдресСервиса - Строка
//      ** Заголовок	- Строка
//
&НаСервере
Процедура ЗаполнитьСписки(ОписаниеСервисаОбнаружения)
	
	ТекущийСписок = Элементы.АдресСервисаЭлектроннойПодписи.СписокВыбора;
	ТекущийСписок.Очистить();
	Для каждого СтрокаКлюча Из ОписаниеСервисаОбнаружения.СервисыСЭП Цикл
		ТекущийСписок.Добавить(СтрокаКлюча.АдресСервиса, СтрокаКлюча.Заголовок);
	КонецЦикла;
	
	ТекущийСписок = Элементы.АдресСервисаЦентраИдентификации.СписокВыбора;
	ТекущийСписок.Очистить();
	Для каждого СтрокаКлюча Из ОписаниеСервисаОбнаружения.СервисыЦИ Цикл
		ТекущийСписок.Добавить(СтрокаКлюча.АдресСервиса, СтрокаКлюча.Заголовок);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти


