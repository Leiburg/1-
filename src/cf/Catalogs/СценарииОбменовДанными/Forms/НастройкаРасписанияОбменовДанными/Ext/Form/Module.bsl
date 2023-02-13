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
	
	УстановитьУсловноеОформление();
	
	Список.Параметры.Элементы[0].Значение = Параметры.УзелИнформационнойБазы;
	Список.Параметры.Элементы[0].Использование = Истина;
	
	Заголовок = НСтр("ru = 'Сценарии синхронизации данных для: [УзелИнформационнойБазы]'");
	Заголовок = СтрЗаменить(Заголовок, "[УзелИнформационнойБазы]", Строка(Параметры.УзелИнформационнойБазы));
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_СценарииОбменовДанными" Тогда
		
		Элементы.Список.Обновить();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Поле = Элементы.ФлагИспользованияЗагрузки Тогда
		
		ВключитьОтключитьЗагрузкуНаСервере(ТекущиеДанные.ФлагИспользованияЗагрузки, ТекущиеДанные.Ссылка);
		
	ИначеЕсли Поле = Элементы.ФлагИспользованияВыгрузки Тогда
		
		ВключитьОтключитьВыгрузкуНаСервере(ТекущиеДанные.ФлагИспользованияВыгрузки, ТекущиеДанные.Ссылка);
		
	ИначеЕсли Поле = Элементы.Наименование Тогда
		
		ИзменитьСценарийОбменаДанными(Неопределено);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Создать(Команда)
	
	ПараметрыФормы = Новый Структура("УзелИнформационнойБазы", Параметры.УзелИнформационнойБазы);
	
	ОткрытьФорму("Справочник.СценарииОбменовДанными.ФормаОбъекта", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьСценарийОбменаДанными(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Ключ", ТекущиеДанные.Ссылка);
	
	ОткрытьФорму("Справочник.СценарииОбменовДанными.ФормаОбъекта", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьОтключитьРегламентноеЗадание(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВключитьОтключитьРегламентноеЗаданиеНаСервере(ТекущиеДанные.Ссылка);
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьОтключитьВыгрузку(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВключитьОтключитьВыгрузкуНаСервере(ТекущиеДанные.ФлагИспользованияВыгрузки, ТекущиеДанные.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьОтключитьЗагрузку(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВключитьОтключитьЗагрузкуНаСервере(ТекущиеДанные.ФлагИспользованияЗагрузки, ТекущиеДанные.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьОтключитьЗагрузкуВыгрузку(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВключитьОтключитьЗагрузкуВыгрузкуНаСервере(ТекущиеДанные.ФлагИспользованияЗагрузки ИЛИ ТекущиеДанные.ФлагИспользованияВыгрузки, ТекущиеДанные.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьСценарий(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Ложь;
	
	// Запускаем выполнение обмена.
	ОбменДаннымиВызовСервера.ВыполнитьОбменДаннымиПоСценариюОбменаДанными(Отказ, ТекущиеДанные.Ссылка);
	
	Если Отказ Тогда
		Сообщение = НСтр("ru = 'Сценарий синхронизации выполнен с ошибками.'");
		Картинка = БиблиотекаКартинок.Ошибка32;
	Иначе
		Сообщение = НСтр("ru = 'Сценарий синхронизации успешно выполнен.'");
		Картинка = Неопределено;
	КонецЕсли;
	ПоказатьОповещениеПользователя(Сообщение,,,Картинка);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Параметры:
//   Ссылка - СправочникСсылка.СценарииОбменовДанными - сценарий обмена.
//
&НаСервереБезКонтекста
Процедура ВключитьОтключитьРегламентноеЗаданиеНаСервере(Ссылка)
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.СценарииОбменовДанными");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Ссылка);
		Блокировка.Заблокировать();
		
		ЗаблокироватьДанныеДляРедактирования(Ссылка);
		СценарийОбъект = Ссылка.ПолучитьОбъект();
		
		СценарийОбъект.ИспользоватьРегламентноеЗадание = Не СценарийОбъект.ИспользоватьРегламентноеЗадание;
		СценарийОбъект.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура ВключитьОтключитьВыгрузкуНаСервере(Знач ФлагИспользованияВыгрузки, Знач СценарийОбменаДанными)
	
	Если ФлагИспользованияВыгрузки Тогда
		
		Справочники.СценарииОбменовДанными.УдалитьВыгрузкуВСценарииОбменаДанными(СценарийОбменаДанными, Параметры.УзелИнформационнойБазы);
		
	Иначе
		
		Справочники.СценарииОбменовДанными.ДобавитьВыгрузкуВСценарииОбменаДанными(СценарийОбменаДанными, Параметры.УзелИнформационнойБазы);
		
	КонецЕсли;
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура ВключитьОтключитьЗагрузкуНаСервере(Знач ФлагИспользованияЗагрузки, Знач СценарийОбменаДанными)
	
	Если ФлагИспользованияЗагрузки Тогда
		
		Справочники.СценарииОбменовДанными.УдалитьЗагрузкуВСценарииОбменаДанными(СценарийОбменаДанными, Параметры.УзелИнформационнойБазы);
		
	Иначе
		
		Справочники.СценарииОбменовДанными.ДобавитьЗагрузкуВСценарииОбменаДанными(СценарийОбменаДанными, Параметры.УзелИнформационнойБазы);
		
	КонецЕсли;
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура ВключитьОтключитьЗагрузкуВыгрузкуНаСервере(Знач ФлагИспользования, Знач СценарийОбменаДанными)
	
	ВключитьОтключитьЗагрузкуНаСервере(ФлагИспользования, СценарийОбменаДанными);
	
	ВключитьОтключитьВыгрузкуНаСервере(ФлагИспользования, СценарийОбменаДанными);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Список.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Список.ФлагИспользования");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветФона", WebЦвета.Лазурный);
	
КонецПроцедуры

#КонецОбласти