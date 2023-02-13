﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Открывает форму выбора Справочника БИК с отбором по переданному БИК.
// Если в списке выбора единственная запись, то выбор в форме осуществляется автоматически.
//
// Параметры:
//  БИК - Строка - банковский идентификационный код.
//  Форма - ФормаКлиентскогоПриложения - форма, из которой открывается форма выбора.
//  ОбработчикОповещения - ОписаниеОповещения - процедура, в которую передается управление после осуществления выбора.
//                                              Если параметр не указан, то будет вызван стандартный обработчик выбора.
//    Параметры процедуры:
//     * БИК - СправочникСсылка.КлассификаторБанков - выбранный элемент.
//     * ДополнительныеПараметры - Произвольный - параметр, переданный в конструкторе описания оповещения.
// 
Процедура ВыбратьИзСправочникаБИК(БИК, Форма, ОбработчикОповещения = Неопределено) Экспорт
	
	Параметры = Новый Структура;
	Параметры.Вставить("БИК", БИК);
	ОткрытьФорму("Справочник.КлассификаторБанков.ФормаВыбора", Параметры, Форма, , , , ОбработчикОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияКлиентПереопределяемый.ПослеНачалаРаботыСистемы.
Процедура ПослеНачалаРаботыСистемы() Экспорт
	
	ПараметрыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске();
	Если ПараметрыКлиента.Свойство("Банки") И ПараметрыКлиента.Банки.ВыводитьОповещениеОНеактуальности Тогда
		ПодключитьОбработчикОжидания("РаботаСБанкамиВывестиОповещениеОНеактуальности", 45, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Обновление классификатора банков.

// Выводит соответствующее оповещение.
//
Процедура ОповеститьКлассификаторУстарел() Экспорт
	
	ПоказатьОповещениеПользователя(
		НСтр("ru = 'Классификатор банков устарел'"),
		НавигационнаяСсылкаФормыЗагрузки(),
		НСтр("ru = 'Обновить классификатор банков'"),
		БиблиотекаКартинок.Предупреждение32,
		СтатусОповещенияПользователя.Важное,
		"КлассификаторБанковУстарел");
	
КонецПроцедуры

// Возвращает навигационную ссылку для оповещений.
//
Функция НавигационнаяСсылкаФормыЗагрузки()
	Возврат "e1cib/command/Обработка.ЗагрузкаКлассификатораБанков.Команда.ЗагрузкаКлассификатораБанков";
КонецФункции

Процедура ОткрытьФормуЗагрузкиКлассификатора() Экспорт
	ПодключитьОбработчикОжидания("РаботаСБанкамиОткрытьФормуЗагрузкиКлассификатора", 0.1, Истина);
КонецПроцедуры

Процедура ПерейтиКЗагрузкеКлассификатора() Экспорт
	ФайловаяСистемаКлиент.ОткрытьНавигационнуюСсылку(НавигационнаяСсылкаФормыЗагрузки());
КонецПроцедуры

Процедура ПредложитьЗагрузкуКлассификатора() Экспорт
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриПолученииОтветаНаВопросОЗагрузкеКлассификатора", ЭтотОбъект);
	ЗаголовокВопроса = НСтр("ru = 'Загрузка классификатора банков'");
	ТекстВопроса = НСтр("ru = 'Классификатор банков еще не загружен. Загрузить сейчас?'");
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить(КодВозвратаДиалога.Да, НСтр("ru = 'Загрузить'"));
	Кнопки.Добавить(КодВозвратаДиалога.Отмена);
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, Кнопки, , Кнопки[0].Значение, ЗаголовокВопроса);

КонецПроцедуры

Процедура ПриПолученииОтветаНаВопросОЗагрузкеКлассификатора(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОткрытьФормуЗагрузкиКлассификатора();
	
КонецПроцедуры

#КонецОбласти
