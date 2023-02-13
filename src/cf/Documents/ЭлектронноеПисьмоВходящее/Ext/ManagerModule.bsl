﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
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
	
	Результат = Новый Массив;
	Результат.Добавить("Важность");
	Результат.Добавить("Ответственный");
	Результат.Добавить("ВзаимодействиеОснование");
	Результат.Добавить("Комментарий");
	Результат.Добавить("ОтправительКонтакт");
	Результат.Добавить("ОтправительПредставление");
	Результат.Добавить("ПолучателиПисьма.Представление");
	Результат.Добавить("ПолучателиПисьма.Контакт");
	Результат.Добавить("ПолучателиКопий.Представление");
	Результат.Добавить("ПолучателиКопий.Контакт");
	Результат.Добавить("ПолучателиОтвета.Представление");
	Результат.Добавить("ПолучателиОтвета.Контакт");
	Результат.Добавить("АдресаУведомленияОПрочтении.Представление");
	Результат.Добавить("АдресаУведомленияОПрочтении.Контакт");
	Возврат Результат;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// СтандартныеПодсистемы.Взаимодействия

// Получает отправителя и адресатов электронного письма.
//
// Параметры:
//  Ссылка  - ДокументСсылка.ЭлектронноеПисьмоВходящее - документ, абонента которого необходимо получить.
//
// Возвращаемое значение:
//   ТаблицаЗначений   - таблица, содержащая колонки "Контакт", "Представление" и "Адрес".
//
Функция ПолучитьКонтакты(Ссылка) Экспорт

	ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящее.УчетнаяЗапись.АдресЭлектроннойПочты КАК УчетнаяЗаписьАдресЭлектроннойПочты
		|ПОМЕСТИТЬ НашАдрес
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее КАК ЭлектронноеПисьмоВходящее
		|ГДЕ
		|	ЭлектронноеПисьмоВходящее.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящее.ОтправительАдрес КАК Адрес,
		|	ПОДСТРОКА(ЭлектронноеПисьмоВходящее.ОтправительПредставление, 1, 1000) КАК Представление,
		|	ЭлектронноеПисьмоВходящее.ОтправительКонтакт КАК Контакт
		|ПОМЕСТИТЬ ВсеКонтакты
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее КАК ЭлектронноеПисьмоВходящее
		|ГДЕ
		|	ЭлектронноеПисьмоВходящее.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Адрес,
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Представление,
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Контакт
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее.ПолучателиПисьма КАК ЭлектронноеПисьмоВходящееПолучателиПисьма
		|ГДЕ
		|	ЭлектронноеПисьмоВходящееПолучателиПисьма.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Адрес,
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Представление,
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Контакт
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее.ПолучателиКопий КАК ЭлектронноеПисьмоВходящееПолучателиКопий
		|ГДЕ
		|	ЭлектронноеПисьмоВходящееПолучателиКопий.Ссылка = &Ссылка
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Адрес,
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Представление,
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Контакт
		|ИЗ
		|	Документ.ЭлектронноеПисьмоВходящее.ПолучателиОтвета КАК ЭлектронноеПисьмоВходящееПолучателиОтвета
		|ГДЕ
		|	ЭлектронноеПисьмоВходящееПолучателиОтвета.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВсеКонтакты.Адрес КАК Адрес,
		|	МАКСИМУМ(ВсеКонтакты.Представление) КАК Представление,
		|	МАКСИМУМ(ВсеКонтакты.Контакт) КАК Контакт
		|ИЗ
		|	ВсеКонтакты КАК ВсеКонтакты
		|		ЛЕВОЕ СОЕДИНЕНИЕ НашАдрес КАК НашАдрес
		|		ПО ВсеКонтакты.Адрес = НашАдрес.УчетнаяЗаписьАдресЭлектроннойПочты
		|ГДЕ
		|	НашАдрес.УчетнаяЗаписьАдресЭлектроннойПочты ЕСТЬ NULL
		|
		|СГРУППИРОВАТЬ ПО
		|	ВсеКонтакты.Адрес";

	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	ТаблицаКонтактов = Запрос.Выполнить().Выгрузить();

	Возврат Взаимодействия.ПреобразоватьТаблицуКонтактовВМассив(ТаблицаКонтактов);
	
КонецФункции

// Конец СтандартныеПодсистемы.Взаимодействия

// СтандартныеПодсистемы.УправлениеДоступом

// Параметры:
//   Ограничение - см. УправлениеДоступомПереопределяемый.ПриЗаполненииОграниченияДоступа.Ограничение.
//
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"РазрешитьЧтениеИзменение
	|ГДЕ
	|	ЗначениеРазрешено(Ответственный, Отключено КАК Ложь)
	|	ИЛИ ЗначениеРазрешено(УчетнаяЗапись, Отключено КАК Ложь)";
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

// СтандартныеПодсистемы.ПодключаемыеКоманды

// Определяет список команд создания на основании.
//
// Параметры:
//  КомандыСозданияНаОсновании - см. СозданиеНаОснованииПереопределяемый.ПередДобавлениемКомандСозданияНаОсновании.КомандыСозданияНаОсновании
//  Параметры - см. СозданиеНаОснованииПереопределяемый.ПередДобавлениемКомандСозданияНаОсновании.Параметры
//
Процедура ДобавитьКомандыСозданияНаОсновании(КомандыСозданияНаОсновании, Параметры) Экспорт
	
	Документы.Встреча.ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании);
	Документы.ЗапланированноеВзаимодействие.ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании);
	Документы.СообщениеSMS.ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании);
	Документы.ТелефонныйЗвонок.ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании);
	
КонецПроцедуры

// Для использования в процедуре ДобавитьКомандыСозданияНаОсновании других модулей менеджеров объектов.
// Добавляет в список команд создания на основании этот объект.
//
// Параметры:
//  КомандыСозданияНаОсновании - см. СозданиеНаОснованииПереопределяемый.ПередДобавлениемКомандСозданияНаОсновании.КомандыСозданияНаОсновании
//
// Возвращаемое значение:
//  СтрокаТаблицыЗначений, Неопределено - описание добавленной команды.
//
Функция ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании) Экспорт
	
	Команда = СозданиеНаОсновании.ДобавитьКомандуСозданияНаОсновании(КомандыСозданияНаОсновании, Метаданные.Документы.ЭлектронноеПисьмоВходящее);
	Если Команда <> Неопределено Тогда
		Команда.Важность = "СмТакже";
	КонецЕсли;
	
	Возврат Команда;
	
КонецФункции

// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	ВзаимодействияСобытия.ОбработкаПолученияДанныхВыбора(Метаданные.Документы.ЭлектронноеПисьмоВходящее.Имя,
		ДанныеВыбора, Параметры, СтандартнаяОбработка);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли



