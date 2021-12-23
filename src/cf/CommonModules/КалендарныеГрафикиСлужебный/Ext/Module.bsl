﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Вызывается при изменении производственных календарей.
//
Процедура ЗапланироватьОбновлениеДанныхЗависимыхОтПроизводственныхКалендарей(Знач УсловияОбновления) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ОчередьЗаданий") Тогда
		
		МодульОчередьЗаданий = ОбщегоНазначения.ОбщийМодуль("ОчередьЗаданий");
		
		ПараметрыМетода = Новый Массив;
		ПараметрыМетода.Добавить(УсловияОбновления);
		ПараметрыМетода.Добавить(Новый УникальныйИдентификатор);

		ПараметрыЗадания = Новый Структура;
		ПараметрыЗадания.Вставить("ИмяМетода", "КалендарныеГрафикиСлужебный.ОбновитьДанныеЗависимыеОтПроизводственныхКалендарей");
		ПараметрыЗадания.Вставить("Параметры", ПараметрыМетода);
		ПараметрыЗадания.Вставить("КоличествоПовторовПриАварийномЗавершении", 3);
		ПараметрыЗадания.Вставить("ОбластьДанных", -1);
		
		УстановитьПривилегированныйРежим(Истина);
		МодульОчередьЗаданий.ДобавитьЗадание(ПараметрыЗадания);
		
	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОчередьЗаданийПереопределяемый.ПриОпределенииПсевдонимовОбработчиков.
Процедура ПриОпределенииПсевдонимовОбработчиков(СоответствиеИменПсевдонимам) Экспорт
	
	СоответствиеИменПсевдонимам.Вставить("КалендарныеГрафикиСлужебный.ОбновитьДанныеЗависимыеОтПроизводственныхКалендарей");
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура для вызова из очереди заданий, помещается туда в ЗапланироватьОбновлениеДанныхЗависимыхОтПроизводственныхКалендарей.
// 
// Параметры:
//  УсловияОбновления - ТаблицаЗначений с условиями обновления графиков.
//  ИдентификаторФайла - УникальныйИдентификатор файла обрабатываемых поставляемых данных.
//
Процедура ОбновитьДанныеЗависимыеОтПроизводственныхКалендарей(Знач УсловияОбновления, Знач ИдентификаторФайла) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		
		МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
		
		// Получение областей данных для обработки.
		ОбластиДляОбновления = МодульПоставляемыеДанные.ОбластиТребующиеОбработки(
			ИдентификаторФайла, "ДанныеПроизводственныхКалендарей");
			
		// Обновление графиков работы по областям данных.
		РаспространитьДанныеПроизводственныхКалендарейПоЗависимымДанным(УсловияОбновления, ОбластиДляОбновления, 
			ИдентификаторФайла, "ДанныеПроизводственныхКалендарей");
			
	КонецЕсли;
		
КонецПроцедуры

// Заполняет данные, зависимые от производственных календарей, по данным производственного календаря по всем ОД.
//
// Параметры:
//  УсловияОбновления - ТаблицаЗначений - таблица с условиями обновления графиков.
//  ОбластиДляОбновления - массив со списком кодов областей.
//  ИдентификаторФайла - УникальныйИдентификатор файла обрабатываемых курсов.
//  КодОбработчика - Строка - код обработчика.
//
Процедура РаспространитьДанныеПроизводственныхКалендарейПоЗависимымДанным(Знач УсловияОбновления, 
	Знач ОбластиДляОбновления, Знач ИдентификаторФайла, Знач КодОбработчика)
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность")
		Или Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.ПоставляемыеДанные") Тогда
		Возврат;
	КонецЕсли;
	
	МодульПоставляемыеДанные = ОбщегоНазначения.ОбщийМодуль("ПоставляемыеДанные");
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	УсловияОбновления.Свернуть("КодПроизводственногоКалендаря, Год");
	
	Для каждого ОбластьДанных Из ОбластиДляОбновления Цикл
		Попытка
			УстановитьПривилегированныйРежим(Истина);
			МодульРаботаВМоделиСервиса.ВойтиВОбластьДанных(ОбластьДанных);
			УстановитьПривилегированныйРежим(Ложь);
		Исключение
			// В области может быть установлен монопольный режим, и тогда в область не войдешь.
			// Такие области надо пропускать.
			УстановитьПривилегированныйРежим(Истина);
			МодульРаботаВМоделиСервиса.ВыйтиИзОбластиДанных();
			УстановитьПривилегированныйРежим(Ложь);
			Продолжить;
		КонецПопытки;
		НачатьТранзакцию();
		Попытка
			КалендарныеГрафики.ЗаполнитьДанныеЗависимыеОтПроизводственныхКалендарей(УсловияОбновления);
			МодульПоставляемыеДанные.ОбластьОбработана(ИдентификаторФайла, КодОбработчика, ОбластьДанных);
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Календарные графики.Распространение производственных календарей'", ОбщегоНазначения.КодОсновногоЯзыка()),
									УровеньЖурналаРегистрации.Ошибка,,,
									ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
		УстановитьПривилегированныйРежим(Истина);
		МодульРаботаВМоделиСервиса.ВыйтиИзОбластиДанных();
		УстановитьПривилегированныйРежим(Ложь);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
