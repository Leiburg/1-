﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Запускает обмен данными, используется в фоновом задании.
//
// Параметры:
//   ПараметрыЗадания - Структура - параметры, необходимые для выполнения процедуры.
//   АдресХранилища   - Строка - адрес временного хранилища.
//
Процедура ВыполнитьЗапускОбменаДанными(ПараметрыЗадания, АдресХранилища) Экспорт
	
	ПараметрыОбмена = ОбменДаннымиСервер.ПараметрыОбмена();
	
	ЗаполнитьЗначенияСвойств(ПараметрыОбмена, ПараметрыЗадания,
		"ВидТранспортаСообщенийОбмена,ВыполнятьЗагрузку,ВыполнятьВыгрузку");
		
	Если ПараметрыЗадания.ВидТранспортаСообщенийОбмена = Перечисления.ВидыТранспортаСообщенийОбмена.WS Тогда
		
		ПараметрыОбмена.ДлительнаяОперация          = ПараметрыЗадания.ДлительнаяОперация;
		ПараметрыОбмена.ДлительнаяОперацияРазрешена = Истина;
		ПараметрыОбмена.ИдентификаторОперации       = ПараметрыЗадания.ИдентификаторДлительнойОперации;
		ПараметрыОбмена.ИдентификаторФайла          = ПараметрыЗадания.ИдентификаторФайлаСообщенияВСервисе;
		ПараметрыОбмена.ПараметрыАутентификации     = ПараметрыЗадания.ПараметрыАутентификации;
		ПараметрыОбмена.ИнтервалОжиданияНаСервере   = 15;
		
	КонецЕсли;
	
	ОбменДаннымиСервер.ПроверитьВозможностьЗапускаОбмена(ПараметрыЗадания.УзелИнформационнойБазы, ПараметрыЗадания.Отказ);
	
	Если Не ПараметрыЗадания.Отказ Тогда
		
		ОбменДаннымиСервер.ВыполнитьОбменДаннымиДляУзлаИнформационнойБазы(
			ПараметрыЗадания.УзелИнформационнойБазы,
			ПараметрыОбмена,
			ПараметрыЗадания.Отказ);
			
		Если ПараметрыЗадания.ВидТранспортаСообщенийОбмена = Перечисления.ВидыТранспортаСообщенийОбмена.WS Тогда
			
			ПараметрыЗадания.ДлительнаяОперация                  = ПараметрыОбмена.ДлительнаяОперация;
			ПараметрыЗадания.ИдентификаторДлительнойОперации     = ПараметрыОбмена.ИдентификаторОперации;
			ПараметрыЗадания.ПараметрыАутентификации             = ПараметрыОбмена.ПараметрыАутентификации;
			
			Если ЗначениеЗаполнено(ПараметрыЗадания.ИдентификаторДлительнойОперации) Тогда
				// Если задание выполняется на корреспонденте, то необходимо будет загрузить полученный файл в базу позднее.
				ПараметрыЗадания.ИдентификаторФайлаСообщенияВСервисе = ПараметрыОбмена.ИдентификаторФайла;
			Иначе
				// Файл с данными уже получен и загружен в базу, загружать его дополнительно нет необходимости.
				ПараметрыЗадания.ИдентификаторФайлаСообщенияВСервисе = "";
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ПоместитьВоВременноеХранилище(ПараметрыЗадания, АдресХранилища);
	
КонецПроцедуры

// Запускает загрузку полученного из интернета файла, используется в фоновом задании.
//
// Параметры:
//   ПараметрыЗадания - Структура - параметры, необходимые для выполнения процедуры.
//   АдресХранилища   - Строка - адрес временного хранилища.
//
Процедура ВыполнитьЗагрузкуПолученногоИзИнтернетаФайла(ПараметрыЗадания, АдресХранилища) Экспорт
	
	ОбменДаннымиСервер.ВыполнитьОбменДаннымиДляУзлаИнформационнойБазыЗавершениеДлительнойОперации(
		ПараметрыЗадания.Отказ,
		ПараметрыЗадания.УзелИнформационнойБазы,
		ПараметрыЗадания.ИдентификаторФайлаСообщенияВСервисе,
		ПараметрыЗадания.ДатаНачалаОперации,
		ПараметрыЗадания.ПараметрыАутентификации);
		
	ПараметрыЗадания.ИдентификаторФайлаСообщенияВСервисе = "";
	ПоместитьВоВременноеХранилище(ПараметрыЗадания, АдресХранилища);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли