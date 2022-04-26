﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	УстановитьУсловноеОформление();
	
	РазделениеВключено = ОбщегоНазначения.РазделениеВключено();
	Если НЕ Пользователи.ЭтоПолноправныйПользователь(, Не РазделениеВключено) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав для открытия списка пользователей информационной базы.'");
	КонецЕсли;
	
	Пользователи.НайтиНеоднозначныхПользователейИБ(Неопределено);
	
	ТипыПользователей.Добавить(Тип("СправочникСсылка.Пользователи"));
	Если ПолучитьФункциональнуюОпцию("ИспользоватьВнешнихПользователей") Тогда
		ТипыПользователей.Добавить(Тип("СправочникСсылка.ВнешниеПользователи"));
	КонецЕсли;
	
	ПоказатьТолькоОбработанныеВКонфигураторе = Истина;
	
	ЗаполнитьПользователейИБ();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ДобавленПользовательИБ"
	 ИЛИ ИмяСобытия = "ИзмененПользовательИБ"
	 ИЛИ ИмяСобытия = "УдаленПользовательИБ"
	 ИЛИ ИмяСобытия = "ОчищеноСопоставлениеСНесуществующимПользователемИБ" Тогда
		
		ЗаполнитьПользователейИБ();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПоказатьТолькоОбработанныеВКонфигуратореПриИзменении(Элемент)
	
	ЗаполнитьПользователейИБ();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПользователиИБ

&НаКлиенте
Процедура ПользователиИБПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.ПользователиИБ.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		МожноУдалить     = Ложь;
		МожноСопоставить = Ложь;
		МожноПерейтиКПользователю  = Ложь;
		МожноОтменитьСопоставление = Ложь;
	Иначе
		МожноУдалить     = Не ЗначениеЗаполнено(ТекущиеДанные.Ссылка);
		МожноСопоставить = Не ЗначениеЗаполнено(ТекущиеДанные.Ссылка);
		МожноПерейтиКПользователю  = ЗначениеЗаполнено(ТекущиеДанные.Ссылка);
		МожноОтменитьСопоставление = ЗначениеЗаполнено(ТекущиеДанные.Ссылка);
	КонецЕсли;
	
	Элементы.ПользователиИБУдалить.Доступность = МожноУдалить;
	
	Элементы.ПользователиИБПерейтиКПользователю.Доступность                = МожноПерейтиКПользователю;
	Элементы.ПользователиИБКонтекстноеМенюПерейтиКПользователю.Доступность = МожноПерейтиКПользователю;
	
	Элементы.ПользователиИБСопоставить.Доступность       = МожноСопоставить;
	Элементы.ПользователиИБСопоставитьСНовым.Доступность = МожноСопоставить;
	
	Элементы.ПользователиИБОтменитьСопоставление.Доступность = МожноОтменитьСопоставление;
	
КонецПроцедуры

&НаКлиенте
Процедура ПользователиИБПередУдалением(Элемент, Отказ)
	
	Отказ = Истина;
	
	Если Не ЗначениеЗаполнено(Элементы.ПользователиИБ.ТекущиеДанные.Ссылка) Тогда
		УдалитьТекущегоПользователяИБ(Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Обновить(Команда)
	
	ЗаполнитьПользователейИБ();
	
КонецПроцедуры

&НаКлиенте
Процедура Сопоставить(Команда)
	
	СопоставитьПользователяИБ();
	
КонецПроцедуры

&НаКлиенте
Процедура СопоставитьСНовым(Команда)
	
	СопоставитьПользователяИБ(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиКПользователю(Команда)
	
	ОткрытьПользователяПоСсылке();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьСопоставление(Команда)
	
	Если Элементы.ПользователиИБ.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить("ОтменитьСопоставление", НСтр("ru = 'Отменить сопоставление'"));
	Кнопки.Добавить("ОставитьСопоставление", НСтр("ru = 'Оставить сопоставление'"));
	
	ПоказатьВопрос(
		Новый ОписаниеОповещения("ОтменитьСопоставлениеПродолжение", ЭтотОбъект),
		НСтр("ru = 'Отмена сопоставления пользователя информационной базы с пользователем в справочнике.
		           |
		           |Отмена сопоставления требуется крайне редко - только если сопоставление было выполнено некорректно, например,
		           |при обновлении информационной базы, поэтому не рекомендуется отменять сопоставление по любой другой причине.'"),
		Кнопки,
		,
		"ОставитьСопоставление");
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ПолноеИмя.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Имя.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияСтандартная.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияОС.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ПользовательОС.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияOpenID.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПользователиИБ.ДобавленВКонфигураторе");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ЦветОсобогоТекста);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ПолноеИмя.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Имя.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияСтандартная.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияОС.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ПользовательОС.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияOpenID.Имя);

	ГруппаОтбора1 = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
	ГруппаОтбора1.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли;

	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПользователиИБ.ИзмененВКонфигураторе");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПользователиИБ.УдаленВКонфигураторе");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ТекстЗапрещеннойЯчейкиЦвет);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Имя.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияСтандартная.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияОС.Имя);

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияOpenID.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПользователиИБ.УдаленВКонфигураторе");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("Текст", НСтр("ru = '<Нет данных>'"));
	Элемент.Оформление.УстановитьЗначениеПараметра("Формат", НСтр("ru = 'БЛ=Нет; БИ=Да'"));

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.АутентификацияОС.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПользователиИБ.ПользовательОС");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	Элемент.Оформление.УстановитьЗначениеПараметра("Формат", НСтр("ru = 'БЛ=; БИ=Да'"));

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПользователейИБ()
	
	ПустойУникальныйИдентификатор = ОбщегоНазначенияКлиентСервер.ПустойУникальныйИдентификатор();
	
	Если Элементы.ПользователиИБ.ТекущаяСтрока <> Неопределено Тогда
		Строка = ПользователиИБ.НайтиПоИдентификатору(Элементы.ПользователиИБ.ТекущаяСтрока);
	Иначе
		Строка = Неопределено;
	КонецЕсли;
	
	ТекущийИдентификаторПользователяИБ =
		?(Строка = Неопределено, ПустойУникальныйИдентификатор, Строка.ИдентификаторПользователяИБ);
	
	ПользователиИБ.Очистить();
	ИдентификаторыНесуществующихПользователейИБ.Очистить();
	ИдентификаторыНесуществующихПользователейИБ.Добавить(ПустойУникальныйИдентификатор);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ПустойУникальныйИдентификатор", ПустойУникальныйИдентификатор);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Ссылка,
	|	Пользователи.Наименование КАК ПолноеИмя,
	|	Пользователи.ИдентификаторПользователяИБ,
	|	ЛОЖЬ КАК ЭтоВнешнийПользователь
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.ИдентификаторПользователяИБ <> &ПустойУникальныйИдентификатор
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВнешниеПользователи.Ссылка,
	|	ВнешниеПользователи.Наименование,
	|	ВнешниеПользователи.ИдентификаторПользователяИБ,
	|	ИСТИНА
	|ИЗ
	|	Справочник.ВнешниеПользователи КАК ВнешниеПользователи
	|ГДЕ
	|	ВнешниеПользователи.ИдентификаторПользователяИБ <> &ПустойУникальныйИдентификатор";
	
	Выгрузка = Запрос.Выполнить().Выгрузить();
	Выгрузка.Индексы.Добавить("ИдентификаторПользователяИБ");
	Выгрузка.Колонки.Добавить("Сопоставлен", Новый ОписаниеТипов("Булево"));
	
	ВсеПользователиИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	
	Для Каждого ПользовательИБ Из ВсеПользователиИБ Цикл
		
		ИзмененВКонфигураторе = Ложь;
		Строка = Выгрузка.Найти(ПользовательИБ.УникальныйИдентификатор, "ИдентификаторПользователяИБ");
		СвойстваПользовательИБ = Пользователи.СвойстваПользователяИБ(ПользовательИБ.УникальныйИдентификатор);
		Если СвойстваПользовательИБ = Неопределено Тогда
			СвойстваПользовательИБ = Пользователи.НовоеОписаниеПользователяИБ();
		КонецЕсли;
		
		Если Строка <> Неопределено Тогда
			Строка.Сопоставлен = Истина;
			Если Строка.ПолноеИмя <> СвойстваПользовательИБ.ПолноеИмя Тогда
				ИзмененВКонфигураторе = Истина;
			КонецЕсли;
		КонецЕсли;
		
		Если ПоказатьТолькоОбработанныеВКонфигураторе
		   И Строка <> Неопределено
		   И Не ИзмененВКонфигураторе Тогда
			
			Продолжить;
		КонецЕсли;
		
		НоваяСтрока = ПользователиИБ.Добавить();
		НоваяСтрока.ПолноеИмя                   = СвойстваПользовательИБ.ПолноеИмя;
		НоваяСтрока.Имя                         = СвойстваПользовательИБ.Имя;
		НоваяСтрока.АутентификацияСтандартная   = СвойстваПользовательИБ.АутентификацияСтандартная;
		НоваяСтрока.АутентификацияОС            = СвойстваПользовательИБ.АутентификацияОС;
		НоваяСтрока.ИдентификаторПользователяИБ = СвойстваПользовательИБ.УникальныйИдентификатор;
		НоваяСтрока.ПользовательОС              = СвойстваПользовательИБ.ПользовательОС;
		НоваяСтрока.АутентификацияOpenID        = СвойстваПользовательИБ.АутентификацияOpenID;
		
		Если Строка = Неопределено Тогда
			// Пользователя ИБ нет в справочнике.
			НоваяСтрока.ДобавленВКонфигураторе = Истина;
		Иначе
			НоваяСтрока.Ссылка                           = Строка.Ссылка;
			НоваяСтрока.СопоставленСВнешнимПользователем = Строка.ЭтоВнешнийПользователь;
			
			НоваяСтрока.ИзмененВКонфигураторе = ИзмененВКонфигураторе;
		КонецЕсли;
		
	КонецЦикла;
	
	Отбор = Новый Структура("Сопоставлен", Ложь);
	Строки = Выгрузка.НайтиСтроки(Отбор);
	Для каждого Строка Из Строки Цикл
		НоваяСтрока = ПользователиИБ.Добавить();
		НоваяСтрока.ПолноеИмя                        = Строка.ПолноеИмя;
		НоваяСтрока.Ссылка                           = Строка.Ссылка;
		НоваяСтрока.СопоставленСВнешнимПользователем = Строка.ЭтоВнешнийПользователь;
		НоваяСтрока.УдаленВКонфигураторе             = Истина;
		ИдентификаторыНесуществующихПользователейИБ.Добавить(Строка.ИдентификаторПользователяИБ);
	КонецЦикла;
	
	Отбор = Новый Структура("ИдентификаторПользователяИБ", ТекущийИдентификаторПользователяИБ);
	Строки = ПользователиИБ.НайтиСтроки(Отбор);
	Если Строки.Количество() > 0 Тогда
		Элементы.ПользователиИБ.ТекущаяСтрока = Строки[0].ПолучитьИдентификатор();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьПользователяИБ(ИдентификаторПользователяИБ, Отказ)
	
	Попытка
		Пользователи.УдалитьПользователяИБ(ИдентификаторПользователяИБ);
	Исключение
		ОбщегоНазначения.СообщитьПользователю(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()), , , , Отказ);
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьПользователяПоСсылке()
	
	ТекущиеДанные = Элементы.ПользователиИБ.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
		ОткрытьФорму(
			?(ТекущиеДанные.СопоставленСВнешнимПользователем,
				"Справочник.ВнешниеПользователи.ФормаОбъекта",
				"Справочник.Пользователи.ФормаОбъекта"),
			Новый Структура("Ключ", ТекущиеДанные.Ссылка));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьТекущегоПользователяИБ(УдалитьСтроку = Ложь)
	
	ПоказатьВопрос(
		Новый ОписаниеОповещения("УдалитьТекущегоПользователяИБЗавершение", ЭтотОбъект, УдалитьСтроку),
		НСтр("ru = 'Удалить пользователя информационной базы?'"),
		РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьТекущегоПользователяИБЗавершение(Ответ, УдалитьСтроку) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		Отказ = Ложь;
		УдалитьПользователяИБ(
			Элементы.ПользователиИБ.ТекущиеДанные.ИдентификаторПользователяИБ, Отказ);
		
		Если Не Отказ И УдалитьСтроку Тогда
			ПользователиИБ.Удалить(Элементы.ПользователиИБ.ТекущиеДанные);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СопоставитьПользователяИБ(СНовым = Ложь)
	
	Если ТипыПользователей.Количество() > 1 Тогда
		ТипыПользователей.ПоказатьВыборЭлемента(
			Новый ОписаниеОповещения("СопоставитьПользователяИБДляТипаЭлемента", ЭтотОбъект, СНовым),
			НСтр("ru = 'Выбор типа данных'"),
			ТипыПользователей[0]);
	Иначе
		СопоставитьПользователяИБДляТипаЭлемента(ТипыПользователей[0], СНовым);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СопоставитьПользователяИБДляТипаЭлемента(ЭлементСписка, СНовым) Экспорт
	
	Если ЭлементСписка = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяСправочника = ?(ЭлементСписка.Значение = Тип("СправочникСсылка.Пользователи"), "Пользователи", "ВнешниеПользователи");
	
	Если Не СНовым Тогда
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("РежимВыбора", Истина);
		ПараметрыФормы.Вставить("ИдентификаторыНесуществующихПользователейИБ", ИдентификаторыНесуществующихПользователейИБ);
		
		ОткрытьФорму("Справочник." + ИмяСправочника + ".ФормаВыбора", ПараметрыФормы,,,,,
			Новый ОписаниеОповещения("СопоставитьПользователяИБСЭлементом", ЭтотОбъект, ИмяСправочника));
	Иначе
		СопоставитьПользователяИБСЭлементом("Новый", ИмяСправочника);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СопоставитьПользователяИБСЭлементом(Элемент, ИмяСправочника) Экспорт
	
	Если Не ЗначениеЗаполнено(Элемент) И Элемент <> "Новый" Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	
	Если Элемент <> "Новый" Тогда
		ПараметрыФормы.Вставить("Ключ", Элемент);
	КонецЕсли;
	
	ПараметрыФормы.Вставить("ИдентификаторПользователяИБ",
		Элементы.ПользователиИБ.ТекущиеДанные.ИдентификаторПользователяИБ);
	
	ОткрытьФорму("Справочник." + ИмяСправочника + ".ФормаОбъекта", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьСопоставлениеПродолжение(Ответ, Контекст) Экспорт
	
	Если Ответ = "ОтменитьСопоставление" Тогда
		ОтменитьСопоставлениеНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОтменитьСопоставлениеНаСервере()
	
	ТекущаяСтрока = ПользователиИБ.НайтиПоИдентификатору(Элементы.ПользователиИБ.ТекущаяСтрока);
	Если ТипЗнч(ТекущаяСтрока.Ссылка) = Тип("СправочникСсылка.Пользователи") Тогда
		ИмяТаблицы = "Справочник.Пользователи";
	Иначе	
		ИмяТаблицы = "Справочник.ВнешниеПользователи";
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить(ИмяТаблицы);
		ЭлементБлокировки.УстановитьЗначение("Ссылка", ТекущаяСтрока.Ссылка);
		Блокировка.Заблокировать();
		
		Объект = ТекущаяСтрока.Ссылка.ПолучитьОбъект();
		Объект.ИдентификаторПользователяИБ = Неопределено;
		ОбновлениеИнформационнойБазы.ЗаписатьДанные(Объект);
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;	
	
	ЗаполнитьПользователейИБ();
	
КонецПроцедуры

#КонецОбласти
