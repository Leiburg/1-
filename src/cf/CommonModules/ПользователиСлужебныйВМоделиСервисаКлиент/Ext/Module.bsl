﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Открывает форму ввода пароля пользователя сервиса.
//
// Параметры:
//  ОбработкаПродолжения      - ОписаниеОповещения - которое нужно обработать после получения пароля.
//  ФормаВладелец             - ФормаКлиентскогоПриложения - которая запрашивает пароль.
//  ПарольПользователяСервиса - Строка - текущий пароль пользователя сервиса.
//
Процедура ЗапроситьПарольДляАутентификацииВСервисе(ОбработкаПродолжения, ФормаВладелец, ПарольПользователяСервиса) Экспорт
	
	Если ПарольПользователяСервиса = Неопределено Тогда
		ОткрытьФорму("ОбщаяФорма.АутентификацияВСервисе", , ФормаВладелец, , , , ОбработкаПродолжения);
	Иначе
		ВыполнитьОбработкуОповещения(ОбработкаПродолжения, ПарольПользователяСервиса);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
