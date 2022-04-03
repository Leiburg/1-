﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Предоставляет данные из Справочника БИК.
// 
// Параметры:
//  БИК      - Строка - банковский идентификационный код.
//  КоррСчет - Строка - корреспондентский счет банка.
//  ТолькоАктуальные - Булево - если Истина, то в результат поиска включаются только действующих участники расчетов.
//
// Возвращаемое значение:
//  ТаблицаЗначений:
//   * Ссылка - СправочникСсылка.КлассификаторБанков
//   * БИК - Строка
//   * КоррСчет - Строка
//   * Наименование - Строка
//   * Город - Строка
//   * Адрес- Строка
//   * Телефоны - Строка
//   * ИНН - Строка
//   * ДеятельностьПрекращена - Булево
//   * СВИФТБИК - Строка
//   * МеждународноеНаименование - Строка
//   * ГородМеждународный - Строка
//   * АдресМеждународный - Строка
//   * Страна - Строка, СправочникСсылка.СтраныМира
//   * БИКРКЦ - Строка
//   * НаименованиеРКЦ - Строка
//   * КоррСчетРКЦ - Строка
//   * ГородРКЦ - Строка
//   * АдресРКЦ - Строка
//   * ИННРКЦ - Строка
//
Функция СведенияБИК(Знач БИК, Знач КоррСчет = Неопределено, ТолькоАктуальные = Истина) Экспорт
	
	ИмяОбработки = "ЗагрузкаКлассификатораБанков";
	Если Метаданные.Обработки.Найти(ИмяОбработки) <> Неопределено Тогда
		Возврат Обработки[ИмяОбработки].СведенияБИК(БИК, КоррСчет, ТолькоАктуальные);
	КонецЕсли;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	СправочникБИК.Ссылка КАК Ссылка,
	|	СправочникБИК.Код КАК БИК,
	|	СправочникБИК.Наименование КАК Наименование,
	|	СправочникБИК.КоррСчет КАК КоррСчет,
	|	СправочникБИК.Город КАК Город,
	|	СправочникБИК.Адрес КАК Адрес,
	|	СправочникБИК.Телефоны КАК Телефоны,
	|	СправочникБИК.ДеятельностьПрекращена КАК ДеятельностьПрекращена,
	|	СправочникБИК.СВИФТБИК КАК СВИФТБИК,
	|	СправочникБИК.МеждународноеНаименование КАК МеждународноеНаименование,
	|	СправочникБИК.ГородМеждународный КАК ГородМеждународный,
	|	СправочникБИК.АдресМеждународный КАК АдресМеждународный,
	|	СправочникБИК.Страна КАК Страна
	|ИЗ
	|	Справочник.КлассификаторБанков КАК СправочникБИК
	|ГДЕ
	|	СправочникБИК.Код = &БИК
	|	И ВЫБОР
	|			КОГДА &КоррСчет = НЕОПРЕДЕЛЕНО
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ СправочникБИК.КоррСчет = &КоррСчет
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ТолькоАктуальные
	|				ТОГДА НЕ СправочникБИК.ДеятельностьПрекращена
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("БИК", БИК);
	Запрос.УстановитьПараметр("КоррСчет", КоррСчет);
	Запрос.УстановитьПараметр("ТолькоАктуальные", ТолькоАктуальные);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

// Получает данные из справочника КлассификаторБанков по значениям БИК и корреспондентского счета банка.
// 
// Параметры:
//  БИК          - Строка - банковский идентификационный код.
//  КоррСчет     - Строка - корреспондентский счет банка.
//  ЗаписьОБанке - СправочникСсылка
//               - Строка - (возвращаемый) найденный банк.
//
Процедура ПолучитьДанныеКлассификатора(БИК = "", КоррСчет = "", ЗаписьОБанке = "") Экспорт
	
	ИмяОбработки = "ЗагрузкаКлассификатораБанков";
	Если Метаданные.Обработки.Найти(ИмяОбработки) <> Неопределено Тогда
		Параметры = Новый Структура;
		Параметры.Вставить("БИК", БИК);
		Параметры.Вставить("КоррСчет", КоррСчет);
		Параметры.Вставить("ЗаписьОБанке", ЗаписьОБанке);
		СтандартнаяОбработка = Истина;
		Обработки[ИмяОбработки].ПриПолученииДанныхКлассификатора(Параметры, СтандартнаяОбработка);
		Если Не СтандартнаяОбработка Тогда
			БИК = Параметры.БИК;
			КоррСчет = Параметры.КоррСчет;
			ЗаписьОБанке = Параметры.ЗаписьОБанке;
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ПустаяСтрока(БИК) Тогда
		ЗаписьОБанке = Справочники.КлассификаторБанков.НайтиПоКоду(БИК);
	ИначеЕсли Не ПустаяСтрока(КоррСчет) Тогда
		ЗаписьОБанке = Справочники.КлассификаторБанков.НайтиПоРеквизиту("КоррСчет", КоррСчет);
	Иначе
		ЗаписьОБанке = "";
	КонецЕсли;
	Если ЗаписьОБанке = Справочники.КлассификаторБанков.ПустаяСсылка() Тогда
		ЗаписьОБанке = "";
	КонецЕсли;
	
КонецПроцедуры

// Возвращает текстовое описание причины, по которой банк отмечен как недействительный.
//
// Параметры:
//  Банк - СправочникСсылка.КлассификаторБанков - банк, для которого необходимо получить текст пояснения.
//
// Возвращаемое значение:
//  ФорматированнаяСтрока - пояснение.
//
Функция ПояснениеНедействительногоБанка(Банк) Экспорт
	
	НаименованиеБанка = Строка(Банк);
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	КлассификаторБанков.Ссылка,
	|	КлассификаторБанков.Код КАК БИК
	|ИЗ
	|	Справочник.КлассификаторБанков КАК КлассификаторБанков
	|ГДЕ
	|	КлассификаторБанков.Ссылка <> &Ссылка
	|	И КлассификаторБанков.Наименование = &Наименование
	|	И НЕ КлассификаторБанков.ДеятельностьПрекращена";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Ссылка", Банк);
	Запрос.УстановитьПараметр("Наименование", НаименованиеБанка);
	Выборка = Запрос.Выполнить().Выбрать();
	
	НовыеРеквизитыБанка = Неопределено;
	Если Выборка.Следующий() Тогда
		НовыеРеквизитыБанка = Новый Структура("Ссылка, БИК", Выборка.Ссылка, Выборка.БИК);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Банк) И ЗначениеЗаполнено(НовыеРеквизитыБанка) Тогда
		Результат = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'БИК банка изменился на <a href = ""%1"">%2</a>'"),
			ПолучитьНавигационнуюСсылку(НовыеРеквизитыБанка.Ссылка), НовыеРеквизитыБанка.БИК);
	Иначе
		Результат = НСтр("ru = 'Деятельность банка прекращена'");
	КонецЕсли;
	
	Возврат СтроковыеФункции.ФорматированнаяСтрока(Результат);
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ЗагрузкаДанныхИзФайлаПереопределяемый.ПриОпределенииСправочниковДляЗагрузкиДанных.
Процедура ПриОпределенииСправочниковДляЗагрузкиДанных(ЗагружаемыеСправочники) Экспорт
	
	// Загрузка в классификатор КлассификаторБанков запрещена.
	СтрокаТаблицы = ЗагружаемыеСправочники.Найти(Метаданные.Справочники.КлассификаторБанков.ПолноеИмя(), "ПолноеИмя");
	Если СтрокаТаблицы <> Неопределено Тогда 
		ЗагружаемыеСправочники.Удалить(СтрокаТаблицы);
	КонецЕсли;
	
КонецПроцедуры

// См. ГрупповоеИзменениеОбъектовПереопределяемый.ПриОпределенииОбъектовСРедактируемымиРеквизитами.
Процедура ПриОпределенииОбъектовСРедактируемымиРеквизитами(Объекты) Экспорт
	Объекты.Вставить(Метаданные.Справочники.КлассификаторБанков.ПолноеИмя(), "РеквизитыНеРедактируемыеВГрупповойОбработке");
КонецПроцедуры

// См. ПользователиПереопределяемый.ПриОпределенииНазначенияРолей.
Процедура ПриОпределенииНазначенияРолей(НазначениеРолей) Экспорт
	
	// ТолькоДляПользователейСистемы.
	НазначениеРолей.ТолькоДляПользователейСистемы.Добавить(
		Метаданные.Роли.ДобавлениеИзменениеБанков.Имя);
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриЗаполненииТиповОбщихДанныхПоддерживающихСопоставлениеСсылокПриЗагрузке.
Процедура ПриЗаполненииТиповОбщихДанныхПоддерживающихСопоставлениеСсылокПриЗагрузке(Типы) Экспорт
	
	Типы.Добавить(Метаданные.Справочники.КлассификаторБанков);
	
КонецПроцедуры

// Параметры:
//   ТекущиеДела - см. ТекущиеДелаСервер.ТекущиеДела.
//
Процедура ПриЗаполненииСпискаТекущихДел(ТекущиеДела) Экспорт
	
	ИмяОбработки = "ЗагрузкаКлассификатораБанков";
	Если Метаданные.Обработки.Найти(ИмяОбработки) = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		Возврат;
	КонецЕсли;
	
	МодульТекущиеДелаСервер = ОбщегоНазначения.ОбщийМодуль("ТекущиеДелаСервер");
	Если ОбщегоНазначения.РазделениеВключено() // В модели сервиса обновляется автоматически.
		Или ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() // В узле РИБ обновляется автоматически.
		Или Не ПравоДоступа("Изменение", Метаданные.Справочники.КлассификаторБанков)
		Или МодульТекущиеДелаСервер.ДелоОтключено("КлассификаторБанков") Тогда
		Возврат;
	КонецЕсли;
	
	Результат = Обработки[ИмяОбработки].АктуальностьКлассификатораБанков();
	
	// Процедура вызывается только при наличии подсистемы "Текущие дела", поэтому здесь
	// не делается проверка существования подсистемы.
	Разделы = МодульТекущиеДелаСервер.РазделыДляОбъекта(Метаданные.Справочники.КлассификаторБанков.ПолноеИмя());
	
	Для Каждого Раздел Из Разделы Цикл
		
		ИдентификаторБанки = "КлассификаторБанков" + СтрЗаменить(Раздел.ПолноеИмя(), ".", "");
		Дело = ТекущиеДела.Добавить();
		Дело.Идентификатор  = ИдентификаторБанки;
		Дело.ЕстьДела       = Результат.КлассификаторУстарел;
		Дело.Важное         = Результат.КлассификаторПросрочен;
		Дело.Представление  = НСтр("ru = 'Классификатор банков устарел'");
		Дело.Подсказка      = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Последнее обновление %1 назад'"), Результат.ВеличинаПросрочкиСтрокой);
		Дело.Форма          = "Обработка.ЗагрузкаКлассификатораБанков.Форма";
		Дело.Владелец       = Раздел;
		
	КонецЦикла;
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске.
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры) Экспорт
	
	ВыводитьОповещениеОНеактуальности = (
		Не ОбщегоНазначения.РазделениеВключено() // В модели сервиса обновляется автоматически.
		И Не ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() // В узле РИБ обновляется автоматически.
		И ПравоДоступа("Изменение", Метаданные.Справочники.КлассификаторБанков) // Пользователь с необходимыми правами.
		И Не РаботаСБанкамиСлужебный.КлассификаторАктуален()); // Классификатор уже обновлен.
	
	ВключитьОповещение = Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ТекущиеДела");
	РаботаСБанкамиПереопределяемый.ПриОпределенииНеобходимостиПоказаПредупрежденияОбУстаревшемКлассификатореБанков(ВключитьОповещение);
	
	Параметры.Вставить("Банки", Новый ФиксированнаяСтруктура("ВыводитьОповещениеОНеактуальности", (ВыводитьОповещениеОНеактуальности И ВключитьОповещение)));
	
КонецПроцедуры

#КонецОбласти
