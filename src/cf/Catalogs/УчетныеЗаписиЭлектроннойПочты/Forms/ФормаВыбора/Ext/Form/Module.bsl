﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.ПоказыватьПерсональныеУчетныеЗаписиПользователей.Видимость =
		Пользователи.ЭтоПолноправныйПользователь();
	
	ПереключитьВидимостьПерсональныхУчетныхЗаписей(Список,
		ПоказыватьПерсональныеУчетныеЗаписиПользователей,
		Пользователи.ТекущийПользователь());
	
	Элементы.ВладелецУчетнойЗаписи.Видимость = ПоказыватьПерсональныеУчетныеЗаписиПользователей;
	
	Если ЗначениеЗаполнено(Параметры.Отбор) Тогда
		Отбор = Новый Структура;
		Отбор.Вставить("ИспользоватьДляОтправки", Истина);
		Отбор.Вставить("ИспользоватьДляПолучения", Истина);
		
		ЗаполнитьЗначенияСвойств(Отбор, Параметры.Отбор);
		
		ПредлагатьНастройкуПочты = РаботаСПочтовымиСообщениями.ДоступнаОтправкаПисем() 
			И РаботаСПочтовымиСообщениями.ДоступныеУчетныеЗаписи(
			Отбор.ИспользоватьДляОтправки, Отбор.ИспользоватьДляПолучения, Истина).Количество() = 0;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПоказыватьПерсональныеУчетныеЗаписиПользователейПриИзменении(Элемент)
	
	ПереключитьВидимостьПерсональныхУчетныхЗаписей(Список,
		ПоказыватьПерсональныеУчетныеЗаписиПользователей,
		ПользователиКлиент.ТекущийПользователь());
	
	Элементы.ВладелецУчетнойЗаписи.Видимость = ПоказыватьПерсональныеУчетныеЗаписиПользователей;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ПереключитьВидимостьПерсональныхУчетныхЗаписей(Список, ПоказыватьПерсональныеУчетныеЗаписиПользователей, ТекущийПользователь)
	СписокПользователей = Новый Массив;
	СписокПользователей.Добавить(ПредопределенноеЗначение("Справочник.Пользователи.ПустаяСсылка"));
	СписокПользователей.Добавить(ТекущийПользователь);
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список, "ВладелецУчетнойЗаписи", СписокПользователей, ВидСравненияКомпоновкиДанных.ВСписке, ,
			Не ПоказыватьПерсональныеУчетныеЗаписиПользователей);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если ПредлагатьНастройкуПочты Тогда
		ПодключитьОбработчикОжидания("НастроитьПочту", 0.1, Истина);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура НастроитьПочту()
	
	РаботаСПочтовымиСообщениямиКлиент.ПроверитьНаличиеУчетнойЗаписиДляОтправкиПочты(Неопределено);
	
КонецПроцедуры


#КонецОбласти