﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Для вызова из обработчика ПриНачальномЗаполненииЭлементов.
// Заполняет колонки с именами ИмяРеквизита_<КодЯзыка> текстовыми значениями для указанных кодов языков.
//
// Параметры:
//  Элемент        - СтрокаТаблицыЗначений - заполняемая строка таблицы. С колонками ИмяРеквизита_КодЯзыка.
//  ИмяРеквизита   - Строка -  имя реквизита. Например, "Наименование"
//  ИсходнаяСтрока - Строка - строка в формате НСтр. Например, "ru = 'Сообщение на русском'; en = 'English message'".
//  КодыЯзыков     - Массив - коды языков, на которых нужно заполнить строки.
// 
// Пример:
//
//  МультиязычностьСервер.ЗаполнитьМультиязычныйРеквизит(Элемент, "Наименование", "ru = 'Сообщение на русском'; en =
//  'English message'", КодыЯзыков);
//
Процедура ЗаполнитьМультиязычныйРеквизит(Элемент, ИмяРеквизита, ИсходнаяСтрока, КодыЯзыков = Неопределено) Экспорт
	
	Для каждого КодЯзыка Из КодыЯзыков Цикл
		ЗначениеПоКодуЯзыка = НСтр(ИсходнаяСтрока, КодЯзыка);
		ЗначениеДляЗаполнения = ?(ЗначениеЗаполнено(ЗначениеПоКодуЯзыка), ЗначениеПоКодуЯзыка, НСтр(ИсходнаяСтрока, ОбщегоНазначения.КодОсновногоЯзыка()));
		Элемент[ИмяЛокализуемогоРеквизита(ИмяРеквизита, КодЯзыка)] = ЗначениеДляЗаполнения;
	КонецЦикла;
	
КонецПроцедуры

// Вызывается из обработчика ПриСозданииНаСервере формы объекта. Добавляет кнопку открытия в поля ввода
// мультиязычных реквизитов на этой форме. Нажатие кнопки открывает окно ввода значения реквизита на всех
// имеющихся в конфигурации языках.
//
// Параметры:
//   Форма  - ФормаКлиентскогоПриложения - форма объекта.
//   Объект - ДанныеФормыСтруктура:
//     * Ссылка - ЛюбаяСсылка
//  ИмяОбъекта - Строка - для форм списка имя динамического списка на форме. По умолчанию, "Список".
//                        Для других форм имя основного реквизита на форме. Следует использовать,
//                        если имя отличается от стандартных: "Объект", "Запись", "Список".
//
Процедура ПриСозданииНаСервере(Форма, Объект = Неопределено, ИмяОбъекта = Неопределено) Экспорт
	
	Если Объект <> Неопределено И МультиязычностьПовтИсп.КонфигурацияИспользуетТолькоОдинЯзык(Объект.Свойство("Представления")) Тогда
		Возврат;
	КонецЕсли;
	
	ТипФормы = МультиязычностьПовтИсп.ОпределитьТипФормы(Форма.ИмяФормы);
	
	Если Объект = Неопределено Тогда
		Если ТипФормы = "ОсновнаяФормаСписка" Или ТипФормы = "ОсновнаяФормаВыбора" Тогда
			Если ТипЗнч(ИмяОбъекта) <> Тип("Строка") Тогда
				ИмяОбъекта = "Список";
			КонецЕсли;
			
			ИзменениеТекстаЗапросаСпискаДляТекущегоЯзыка(Форма, ИмяОбъекта);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	СписокРеквизитовФормы = Форма.ПолучитьРеквизиты();
	СоздатьПараметрыМультиязычныхРеквизитов = Истина;
	Для Каждого Реквизит Из СписокРеквизитовФормы Цикл
		Если Реквизит.Имя = "ПараметрыМультиязычныхРеквизитов" Тогда
			СоздатьПараметрыМультиязычныхРеквизитов = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Если СоздатьПараметрыМультиязычныхРеквизитов Тогда
		ДобавляемыеРеквизиты = Новый Массив;
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("ПараметрыМультиязычныхРеквизитов", Новый ОписаниеТипов(),,, Истина));
		Форма.ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	КонецЕсли;
	
	Форма.ПараметрыМультиязычныхРеквизитов = Новый Структура;
	
	ОбъектМетаданные = ОбъектМетаданных(Объект);

	Если ТипЗнч(ИмяОбъекта) <> Тип("Строка") Тогда
		ИмяОбъекта = ?(ОбщегоНазначения.ЭтоРегистр(ОбъектМетаданные), "Запись", "Объект");
	КонецЕсли;
	
	НаименованияРеквизитов = НаименованияЛокализуемыхРеквизитовОбъекта(ОбъектМетаданные, ИмяОбъекта + ".");
	
	Для каждого Элемент Из Форма.Элементы Цикл
		
		Если ТипЗнч(Элемент) = Тип("ПолеФормы") И НаименованияРеквизитов[Элемент.ПутьКДанным] = Истина Тогда
			Элемент.КнопкаОткрытия = Истина;
			Элемент.УстановитьДействие("Открытие", "Подключаемый_Открытие");
			Форма.ПараметрыМультиязычныхРеквизитов.Вставить(Элемент.Имя, Элемент.ПутьКДанным);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Вызывается из обработчика ПриЧтениеНаСервере формы объекта для заполнения значений мультиязычных
// реквизитов формы на текущем языке пользователя.
//
// Параметры:
//  Форма         - ФормаКлиентскогоПриложения - форма объекта.
//  ТекущийОбъект - Произвольный - объект, который был получен в обработчике формы ПриЧтенииНаСервере.
//  ИмяОбъекта - Строка - имя основного реквизита на форме. Следует использовать,
//                        если имя отличается от стандартных: "Объект", "Запись", "Список".
//
Процедура ПриЧтенииНаСервере(Форма, ТекущийОбъект, ИмяОбъекта = Неопределено) Экспорт
	
	Если МультиязычныеСтрокиВРеквизитах(ТекущийОбъект.Метаданные()) И ЭтоОсновнойЯзык() Тогда
		Возврат;
	КонецЕсли;
	
	ОбъектМетаданных = ОбъектМетаданных(ТекущийОбъект);
	Если ОбщегоНазначения.ЭтоРегистр(ОбъектМетаданных) Тогда
		ПриЧтенииПредставленийНаСервере(ТекущийОбъект);
		Если ТипЗнч(ИмяОбъекта) <> Тип("Строка") Тогда
			ИмяОбъекта = "Запись";
		КонецЕсли;
	Иначе
		Если ТипЗнч(ИмяОбъекта) <> Тип("Строка") Тогда
			ИмяОбъекта = "Объект";
		КонецЕсли;
		ТекущийОбъект.ПриЧтенииПредставленийНаСервере();
	КонецЕсли;
	
	Форма.ЗначениеВРеквизитФормы(ТекущийОбъект, ИмяОбъекта);
	
КонецПроцедуры

// Вызывается из обработчика ПередЗаписьюНаСервере формы объекта или при программной записи объекта
// для записи значений мультиязычных реквизитов в соответствии с текущим языком пользователя.
//
// Параметры:
//  ТекущийОбъект - БизнесПроцессОбъект
//                - ДокументОбъект
//                - ЗадачаОбъект
//                - ПланВидовРасчетаОбъект
//                - ПланВидовХарактеристикОбъект
//                - ПланОбменаОбъект
//                - ПланСчетовОбъект
//                - СправочникОбъект - записываемый объект.
//
Процедура ПередЗаписьюНаСервере(ТекущийОбъект) Экспорт
	
	ОбъектМетаданных = ОбъектМетаданных(ТекущийОбъект);
	Если МультиязычныеСтрокиВРеквизитах(ОбъектМетаданных) Тогда
		
		Если ТекущийЯзык().КодЯзыка = ОбщегоНазначения.КодОсновногоЯзыка() Тогда
			Возврат;
		КонецЕсли;
		
		СуффиксТекущегоЯзыка  = "";
		
		Если СтрСравнить(ОбщегоНазначения.КодОсновногоЯзыка(), ТекущийЯзык().КодЯзыка) <> 0 Тогда
			СуффиксТекущегоЯзыка = СуффиксТекущегоЯзыка();
		КонецЕсли;
		
		ИменаЛокализуемыхРеквизитов = НаименованияЛокализуемыхРеквизитовОбъекта(ОбъектМетаданных);
		
		Для Каждого Реквизит Из ИменаЛокализуемыхРеквизитов Цикл
			
			Значение = ТекущийОбъект[Реквизит.Ключ];
			ТекущийОбъект[Реквизит.Ключ] = ТекущийОбъект[Реквизит.Ключ + СуффиксТекущегоЯзыка];
			ТекущийОбъект[Реквизит.Ключ + СуффиксТекущегоЯзыка] = Значение;
			
		КонецЦикла;
		
		Возврат;
	КонецЕсли;
	
	Реквизиты = Новый Массив;
	Для каждого Реквизит Из ТекущийОбъект.Ссылка.Метаданные().ТабличныеЧасти.Представления.Реквизиты Цикл
		Если СтрСравнить(Реквизит.Имя, "КодЯзыка") = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Реквизиты.Добавить(Реквизит.Имя);
	КонецЦикла;
	
	Отбор = Новый Структура();
	Отбор.Вставить("КодЯзыка", ТекущийЯзык().КодЯзыка);
	НайденныеСтроки = ТекущийОбъект.Представления.НайтиСтроки(Отбор);
	
	Если НайденныеСтроки.Количество() > 0 Тогда
		Представление = НайденныеСтроки[0];
	Иначе
		Представление = ТекущийОбъект.Представления.Добавить();
		Представление.КодЯзыка = ТекущийЯзык().КодЯзыка;
	КонецЕсли;
	
	Для каждого ИмяРеквизита Из Реквизиты Цикл
		Представление[ИмяРеквизита] = ТекущийОбъект[ИмяРеквизита];
	КонецЦикла;
	
	Отбор.КодЯзыка =  Метаданные.ОсновнойЯзык.КодЯзыка;
	НайденныеСтроки = ТекущийОбъект.Представления.НайтиСтроки(Отбор);
	Если НайденныеСтроки.Количество() > 0 Тогда
		Для каждого ИмяРеквизита Из Реквизиты Цикл
			ТекущийОбъект[ИмяРеквизита] = НайденныеСтроки[0][ИмяРеквизита];
		КонецЦикла;
		ТекущийОбъект.Представления.Удалить(НайденныеСтроки[0]);
	КонецЕсли;
	
	ТекущийОбъект.Представления.Свернуть("КодЯзыка", СтрСоединить(Реквизиты, ","));
	
КонецПроцедуры

// Вызывается из модуля объекта для заполнения значений мультиязычных
// реквизитов объекта на текущем языке пользователя.
//
// Параметры:
//  Объект - БизнесПроцессОбъект
//         - ДокументОбъект
//         - ЗадачаОбъект
//         - ПланВидовРасчетаОбъект
//         - ПланВидовХарактеристикОбъект
//         - ПланОбменаОбъект
//         - ПланСчетовОбъект
//         - СправочникОбъект - объект данных.
//
Процедура ПриЧтенииПредставленийНаСервере(Объект) Экспорт
	
	ОбъектМетаданных = ОбъектМетаданных(Объект);
	ЭтоРегистр = ОбщегоНазначения.ЭтоРегистр(ОбъектМетаданных);
	
	Если ЭтоРегистр Или МультиязычныеСтрокиВРеквизитах(ОбъектМетаданных) Тогда
		
		Если ЭтоОсновнойЯзык() Тогда
			Возврат;
		КонецЕсли;
		
		ИменаЛокализуемыхРеквизитов = НаименованияЛокализуемыхРеквизитовОбъекта(ОбъектМетаданных);
		
		СуффиксТекущегоЯзыка  = "";
		
		Если СтрСравнить(Константы.ОсновнойЯзык.Получить(), ТекущийЯзык().КодЯзыка) <> 0 Тогда
			СуффиксТекущегоЯзыка = СуффиксТекущегоЯзыка();
		КонецЕсли;
		
		Для Каждого Реквизит Из ИменаЛокализуемыхРеквизитов Цикл
			
			Значение = Объект[Реквизит.Ключ];
			Объект[Реквизит.Ключ] = Объект[Реквизит.Ключ + СуффиксТекущегоЯзыка];
			Объект[Реквизит.Ключ + СуффиксТекущегоЯзыка] = Значение;
			
			Если ПустаяСтрока(Объект[Реквизит.Ключ]) Тогда
				Объект[Реквизит.Ключ] = Значение;
			КонецЕсли;
			
		КонецЦикла;
		
		Возврат;
		
	КонецЕсли;
	
	Для каждого Реквизит Из ОбъектМетаданных.ТабличныеЧасти.Представления.Реквизиты Цикл
		
		Если СтрСравнить(Реквизит.Имя, "КодЯзыка") = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяРеквизита = Реквизит.Имя;
		
		Отбор = Новый Структура();
		Отбор.Вставить("КодЯзыка", Метаданные.ОсновнойЯзык.КодЯзыка);
		НайденныеСтроки = Объект.Представления.НайтиСтроки(Отбор);
	
		Если НайденныеСтроки.Количество() > 0 Тогда
			Представление = НайденныеСтроки[0];
		Иначе
			Представление = Объект.Представления.Добавить();
			Представление.КодЯзыка = Метаданные.ОсновнойЯзык.КодЯзыка;
		КонецЕсли;
		Представление[ИмяРеквизита] = Объект[ИмяРеквизита];
		
		Отбор = Новый Структура();
		Отбор.Вставить("КодЯзыка", ТекущийЯзык().КодЯзыка);
		НайденныеСтроки = Объект.Представления.НайтиСтроки(Отбор);
		
		Если НайденныеСтроки.Количество() > 0 И ЗначениеЗаполнено(НайденныеСтроки[0][ИмяРеквизита]) Тогда
			Объект[ИмяРеквизита] = НайденныеСтроки[0][ИмяРеквизита];
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Вызывается из обработчика ОбработкаПолученияДанныхВыбора для формирования списка при вводе по строке,
// автоподборе текста и быстром выбора, а также при выполнении метода ПолучитьДанныеВыбора.
// Список содержит варианты на всех языках с учетом реквизитов определенных в свойстве ВводПоСтроке.
//
// Параметры:
//  ДанныеВыбора         - СписокЗначений - данные для выбора.
//  Параметры            - Структура - содержит параметры выбора.
//  СтандартнаяОбработка - Булево  - данный параметр передается признак выполнения стандартной (системной) обработки события.
//  ОбъектМетаданных     - ОбъектМетаданныхБизнесПроцесс
//                       - ОбъектМетаданныхДокумент
//                       - ОбъектМетаданныхЗадача
//                       - ОбъектМетаданныхПланВидовРасчета
//                       - ОбъектМетаданныхПланВидовХарактеристик
//                       - ОбъектМетаданныхПланОбмена
//                       - ОбъектМетаданныхПланСчетов
//                       - ОбъектМетаданныхСправочник
//                       - ОбъектМетаданныхТаблица - объект метаданных, для которого формируется список выбора.
//
Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Знач Параметры, СтандартнаяОбработка, ОбъектМетаданных) Экспорт
	
	Если МультиязычностьПовтИсп.КонфигурацияИспользуетТолькоОдинЯзык(ОбъектМетаданных.ТабличныеЧасти.Найти("Представления") = Неопределено) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	ПоляВводаПоСтроке = ОбъектМетаданных.ВводПоСтроке;
	Поля              = Новый Массив;
	
	НаименованияЛокализуемыхРеквизитов = НаименованияЛокализуемыхРеквизитовОбъекта(ОбъектМетаданных);
	Для каждого Поле Из ПоляВводаПоСтроке Цикл
		Если НаименованияЛокализуемыхРеквизитов.Получить(Поле.Имя) = Истина Тогда
			
			Поля.Добавить("Таблица." + Поле.Имя + " ПОДОБНО &СтрокаПоиска");
			
			Если ИспользуетсяПервыйДополнительныйЯзык() Тогда
				Поля.Добавить("Таблица." + Поле.Имя + "Язык1 ПОДОБНО &СтрокаПоиска");
			КонецЕсли;
			
			Если ИспользуетсяВторойДополнительныйЯзык() Тогда
				Поля.Добавить("Таблица." + Поле.Имя + "Язык2 ПОДОБНО &СтрокаПоиска");
			КонецЕсли;

		Иначе
			Поля.Добавить("Таблица." + Поле.Имя + " ПОДОБНО &СтрокаПоиска");
		КонецЕсли;
	КонецЦикла;
	
	ШаблонЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 20
	|	Таблица.Ссылка КАК Ссылка
	|ИЗ
	|	&ИмяОбъекта КАК Таблица
	|ГДЕ
	|	&УсловияОтбора";
	
	ТекстЗапроса = СтрЗаменить(ШаблонЗапроса, "&ИмяОбъекта", ОбъектМетаданных.ПолноеИмя());
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&УсловияОтбора", СтрСоединить(Поля, " ИЛИ "));
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Запрос.УстановитьПараметр("СтрокаПоиска", "%" + Параметры.СтрокаПоиска +"%");
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	ДанныеВыбора = Новый СписокЗначений;
	Пока РезультатЗапроса.Следующий() Цикл
		ДанныеВыбора.Добавить(РезультатЗапроса.Ссылка, РезультатЗапроса.Ссылка);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция СведенияОбЯзыках() Экспорт
	Возврат МультиязычностьПовтИсп.СведенияОбЯзыках();
КонецФункции

Функция ЯзыкиКонфигурации() Экспорт
	
	Языки = Новый Массив;
	Для каждого Язык Из Метаданные.Языки Цикл
		Языки.Добавить(Язык.КодЯзыка);
	КонецЦикла;
	
	Возврат Языки;
	
КонецФункции

Функция ИмяРеквизитаБезСуффиксаЯзык(Знач ИмяРеквизита) Экспорт
	
	Если ЭтоЛокализуемыйРеквизит(ИмяРеквизита) Тогда
		Возврат Лев(ИмяРеквизита, СтрДлина(ИмяРеквизита) - ДлинаСуффиксаЯзыка());
	КонецЕсли;
	
	Возврат ИмяРеквизита;
	
КонецФункции

Функция ПризнакЛокализуемогоРеквизита() Экспорт
	Возврат "Локализуемый";
КонецФункции

Функция МультиязычныеСтрокиВРеквизитах(ОбъектМетаданных) Экспорт
	
	ПолноеИмя = ОбъектМетаданных.ПолноеИмя();
	Если СтрНачинаетсяС(ПолноеИмя, "Справочник")
		Или СтрНачинаетсяС(ПолноеИмя, "Документ")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланВидовХарактеристик")
		Или СтрНачинаетсяС(ПолноеИмя, "Задача")
		Или СтрНачинаетсяС(ПолноеИмя, "БизнесПроцесс")
		Или СтрНачинаетсяС(ПолноеИмя, "Обработка")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланВидовРасчета")
		Или СтрНачинаетсяС(ПолноеИмя, "Отчет")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланСчетов")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланОбмена") Тогда
		Возврат ОбъектМетаданных.ТабличныеЧасти.Найти("Представления") = Неопределено;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция МультиязычныеРеквизитыОбъекта(ОбъектИлиСсылка) Экспорт
	
	ТипОбъекта = ТипЗнч(ОбъектИлиСсылка);
	
	Если ТипОбъекта = Тип("Строка") Тогда
		МетаданныеОбъекта = Метаданные.НайтиПоПолномуИмени(ОбъектИлиСсылка);
	ИначеЕсли ОбщегоНазначения.ЭтоСсылка(ТипОбъекта) Тогда
		МетаданныеОбъекта = ОбъектИлиСсылка.Метаданные();
	Иначе
		МетаданныеОбъекта = ОбъектИлиСсылка;
	КонецЕсли;
	
	Возврат НаименованияЛокализуемыхРеквизитовОбъекта(МетаданныеОбъекта);
	
КонецФункции

Функция ОбновитьМультиязычныеСтрокиПредопределенныхЭлементов(СсылкиНаОбъекты, ОбъектМетаданных) Экспорт
	
	Результат = Новый Структура();
	Результат.Вставить("ПроблемныхОбъектов", 0);
	Результат.Вставить("ОбъектовОбработано", 0);
	
	НастройкиОбновление = НастройкиОбновлениеПредопределенныхДанных(ОбъектМетаданных);
	
	Пока СсылкиНаОбъекты.Следующий() Цикл
		
		Попытка
			
			ОбновитьМультиязычныеСтрокиПредопределенногоЭлемента(СсылкиНаОбъекты, НастройкиОбновление);
			Результат.ОбъектовОбработано = Результат.ОбъектовОбработано + 1;
			
		Исключение
			// Если не удалось обработать элемент, повторяем попытку снова.
			Результат.ПроблемныхОбъектов = Результат.ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать элемент: %1 по причине: %2'"),
				СсылкиНаОбъекты.Ссылка, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
			ОбъектМетаданных, СсылкиНаОбъекты.Ссылка, ТекстСообщения);
			
		КонецПопытки;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ИзменениеТекстаЗапросаСпискаДляТекущегоЯзыка(Форма, ИмяСписка = "Список") Экспорт
	
	СуффиксЯзыка = СуффиксТекущегоЯзыка();
	
	Если ПустаяСтрока(СуффиксЯзыка) Тогда
		Возврат;
	КонецЕсли;
	
	Список = Форма[ИмяСписка];
	Если ПустаяСтрока(Список.ТекстЗапроса) Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Список.ОсновнаяТаблица) Тогда
		ИмяОбъектаМетаданных = Список.ОсновнаяТаблица;
	Иначе
		НаборЧастейПутиОбъектаМетаданных = СтрРазделить(Форма.ИмяФормы, ".");
		ИмяОбъектаМетаданных = НаборЧастейПутиОбъектаМетаданных[0] + "." + НаборЧастейПутиОбъектаМетаданных[1];
	КонецЕсли;
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ИмяОбъектаМетаданных);
	ЛокализуемыеРеквизиты = ЛокализуемыеРеквизитыОбъектаДляТекущегоЯзыка(ОбъектМетаданных);
	
	МодельЗапроса = Новый СхемаЗапроса;
	МодельЗапроса.УстановитьТекстЗапроса(Список.ТекстЗапроса);
	
	Для Каждого ПакетЗапроса Из МодельЗапроса.ПакетЗапросов Цикл
		Для Каждого ОператорЗапроса Из ПакетЗапроса.Операторы Цикл
			Для Каждого ИсточникЗапроса Из ОператорЗапроса.Источники Цикл
				Если ТипЗнч(ИсточникЗапроса.Источник) <> Тип("ВложенныйЗапросСхемыЗапроса")
					И СтрНачинаетсяС(ИсточникЗапроса.Источник.ИмяТаблицы, ИмяОбъектаМетаданных) Тогда
					
					Для каждого ОписаниеРеквизита Из ЛокализуемыеРеквизиты Цикл
						
						ИмяОсновногоРеквизита = Лев(ОписаниеРеквизита.Ключ, СтрДлина(ОписаниеРеквизита.Ключ) - ДлинаСуффиксаЯзыка());
						ПолноеИмя = ИсточникЗапроса.Источник.Псевдоним + "."+ ИмяОсновногоРеквизита;
						
						Для Индекс = 0 По ОператорЗапроса.ВыбираемыеПоля.Количество() - 1 Цикл
							
							ВыбираемоеПолеЗапроса = ОператорЗапроса.ВыбираемыеПоля.Получить(Индекс);
							Если ТипЗнч(ВыбираемоеПолеЗапроса) <> Тип("ВыражениеСхемыЗапроса") Тогда
								Продолжить;
							КонецЕсли;
							
							ВыбираемоеПоле = Строка(ВыбираемоеПолеЗапроса);
							Позиция = СтрНайти(ВыбираемоеПоле, ПолноеИмя);
							
							Если Позиция = 0 Тогда
								Продолжить;
							КонецЕсли;
							
							ТекстВыбораПоля = ИсточникЗапроса.Источник.Псевдоним + "." + ОписаниеРеквизита.Ключ;
							
							Если СтрСравнить(ВыбираемоеПоле, ПолноеИмя) = 0 Тогда
								
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя, ТекстВыбораПоля);
								
							Иначе
								
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя + Символы.ПС,
									ТекстВыбораПоля + Символы.ПС);
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя + " ",
									ТекстВыбораПоля + " " );
								ВыбираемоеПоле = СтрЗаменить(ВыбираемоеПоле, ПолноеИмя + ")",
									ТекстВыбораПоля + ")" );
								
							КонецЕсли;
							
							ОператорЗапроса.ВыбираемыеПоля.Установить(Индекс, Новый ВыражениеСхемыЗапроса(ВыбираемоеПоле));
							
							Если ПакетЗапроса.Колонки.Найти(ИмяОсновногоРеквизита) = Неопределено Тогда
								ПакетЗапроса.Колонки.Получить(Индекс).Псевдоним = ИмяОсновногоРеквизита;
							КонецЕсли;
							
						КонецЦикла;
						
					КонецЦикла;
					
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Список.ТекстЗапроса = МодельЗапроса.ПолучитьТекстЗапроса();
	
КонецПроцедуры

Функция СуффиксТекущегоЯзыка() Экспорт
	
	Возврат СуффиксЯзыка(ТекущийЯзык().КодЯзыка);
	
КонецФункции

// По коду языка возвращает суффикс "Язык1" или "Язык2".
//
Функция СуффиксЯзыка(Язык) Экспорт
	
	Если Язык = Константы.ДополнительныйЯзык1.Получить() Тогда
		Возврат "Язык1";
	КонецЕсли;
	
	Если Язык = Константы.ДополнительныйЯзык2.Получить() Тогда
		Возврат "Язык2";
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

// Возвращает метаданные по коду языка конфигурации.
//
// Параметры:
//   КодЯзыка - Строка - код языка, например "en" (как задано в свойстве КодЯзыка метаданных ОбъектМетаданных: Язык).
//
// Возвращаемое значение:
//   ОбъектМетаданныхЯзык - если найден по переданному коду языка, иначе Неопределено.
//   
Функция ЯзыкПоКоду(Знач КодЯзыка) Экспорт
	Для каждого Язык Из Метаданные.Языки Цикл
		Если Язык.КодЯзыка = КодЯзыка Тогда
			Возврат Язык;
		КонецЕсли;
	КонецЦикла;
	Возврат Неопределено;
КонецФункции	

Функция ИспользуетсяПервыйДополнительныйЯзык() Экспорт
	
	Возврат Константы.ИспользоватьДополнительныйЯзык1.Получить() = Истина;
	
КонецФункции

Функция ИспользуетсяВторойДополнительныйЯзык() Экспорт
	
	Возврат Константы.ИспользоватьДополнительныйЯзык2.Получить() = Истина;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Начальное заполнение элементов данными.

// Параметры:
//  СсылкаНаОбъект - СправочникСсылка
//                 - ПланВидовХарактеристикСсылка
//  НастройкиОбновления - Структура:
//   * ПредопределенныеДанные - ТаблицаЗначений
//   * ОсновнойЯзык - Строка
//   * КодЯзыка2 - Строка
//   * КодЯзыка1 - Строка
//   * ЛокализуемыеРеквизитыОбъекта - Соответствие
// 
Процедура ОбновитьМультиязычныеСтрокиПредопределенногоЭлемента(СсылкаНаОбъект, НастройкиОбновления) Экспорт
	
	ИмяПредопределенныхДанных = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СсылкаНаОбъект.Ссылка, "ИмяПредопределенныхДанных");
	Если Не ЗначениеЗаполнено(ИмяПредопределенныхДанных) Тогда
		ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(СсылкаНаОбъект.Ссылка);
		Возврат;
	КонецЕсли;
	
	Элемент = НастройкиОбновления.ПредопределенныеДанные.Найти(ИмяПредопределенныхДанных, "ИмяПредопределенныхДанных");
	
	Если Элемент = Неопределено Тогда
		ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(СсылкаНаОбъект.Ссылка);
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить(НастройкиОбновления.ИмяОбъектМетаданных);
		ЭлементБлокировки.УстановитьЗначение("Ссылка", СсылкаНаОбъект.Ссылка);
		Блокировка.Заблокировать();
		
		Объект = СсылкаНаОбъект.Ссылка.ПолучитьОбъект();
		Если Объект = Неопределено Тогда // объект может быть уже удален в других сеансах
			ОтменитьТранзакцию();
			Возврат;
		КонецЕсли;
		ЗаблокироватьДанныеДляРедактирования(СсылкаНаОбъект.Ссылка);
		
		Для каждого ЛокализуемыйРеквизитОбъекта Из НастройкиОбновления.ЛокализуемыеРеквизитыОбъекта Цикл
			Имя = ЛокализуемыйРеквизитОбъекта.Ключ;
			Объект[Имя] = Элемент[ИмяЛокализуемогоРеквизита(Имя, НастройкиОбновления.ОсновнойЯзык)];
			
			Если ИспользуетсяПервыйДополнительныйЯзык() И ЗначениеЗаполнено(НастройкиОбновления.КодЯзыка1) Тогда
				Объект[Имя + "Язык1"] = Элемент[ИмяЛокализуемогоРеквизита(Имя, НастройкиОбновления.КодЯзыка1)];
			КонецЕсли;
			Если ИспользуетсяВторойДополнительныйЯзык()  И ЗначениеЗаполнено(НастройкиОбновления.КодЯзыка2) Тогда
				Объект[Имя + "Язык2"] = Элемент[ИмяЛокализуемогоРеквизита(Имя, НастройкиОбновления.КодЯзыка2)];
			КонецЕсли;
			
		КонецЦикла;
		ОбновлениеИнформационнойБазы.ЗаписатьОбъект(Объект);
		ЗафиксироватьТранзакцию();
		
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
		
	
КонецПроцедуры

Функция НастройкиОбновлениеПредопределенныхДанных(ОбъектМетаданных) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ЛокализуемыеРеквизитыОбъекта", Новый Соответствие);
	Результат.Вставить("КодЯзыка1", КодПервогоДополнительногоЯзыкаИнформационнойБазы());
	Результат.Вставить("КодЯзыка2", КодВторогоДополнительногоЯзыкаИнформационнойБазы());
	Результат.Вставить("ОсновнойЯзык", ОбщегоНазначения.КодОсновногоЯзыка());
	Результат.Вставить("ИмяОбъектМетаданных", ОбъектМетаданных.ПолноеИмя());
	Результат.Вставить("ПредопределенныеДанные", Неопределено);
	
	МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(Результат.ИмяОбъектМетаданных);
	
	Результат.ЛокализуемыеРеквизитыОбъекта = НаименованияЛокализуемыхРеквизитовОбъекта(ОбъектМетаданных);
	Результат.ПредопределенныеДанные = ОбновлениеИнформационнойБазыСлужебный.ПредопределенныеДанныеОбъекта(ОбъектМетаданных, МенеджерОбъекта, Результат.ЛокализуемыеРеквизитыОбъекта);
	
	ОбновлениеИнформационнойБазыСлужебный.НастройкиПредопределенныхЭлементов(МенеджерОбъекта, Результат.ПредопределенныеДанные);
	
	Возврат Результат;
	
КонецФункции

Функция МультиязычныеСтрокиРеквизитовИзменены(ПоставляемыеСведения, ДанныеЗапроса, ЛокализуемыеРеквизитыОбъекта, ПараметрыРегистрации) Экспорт
	
	Для каждого ОписаниеРеквизита Из ЛокализуемыеРеквизитыОбъекта Цикл
		
		Если МультиязычныеСтрокиРеквизитаИзменены(ПоставляемыеСведения, ДанныеЗапроса,
				ОписаниеРеквизита.Ключ, ПараметрыРегистрации) Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция МультиязычныеСтрокиРеквизитаИзменены(ПоставляемыеСведения, ДанныеЗапроса, ИмяРеквизита, ПараметрыРегистрации) Экспорт
	
	СведенияОбЯзыках = МультиязычностьПовтИсп.СведенияОбЯзыках();
	
	ЗначениеОсновногоЯзыка = ПоставляемыеСведения[ИмяЛокализуемогоРеквизита(ИмяРеквизита, СведенияОбЯзыках.ОсновнойЯзык)];
	Если ПустаяСтрока(ЗначениеОсновногоЯзыка) И ЗначениеЗаполнено(ПоставляемыеСведения[ИмяРеквизита]) Тогда
		ЗначениеОсновногоЯзыка = ПоставляемыеСведения[ИмяРеквизита];
	КонецЕсли;
	
	Если СтрСравнить(ЗначениеОсновногоЯзыка, ДанныеЗапроса[ИмяРеквизита]) <> 0 Тогда
		
		Если ПустаяСтрока(ЗначениеОсновногоЯзыка) Тогда
			Если Не ПараметрыРегистрации.ПропускатьПустые Тогда
				Возврат Истина;
			КонецЕсли;
		Иначе
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СведенияОбЯзыках.Язык1)
		И СтрСравнить(ПоставляемыеСведения[ИмяЛокализуемогоРеквизита(ИмяРеквизита, СведенияОбЯзыках.Язык1)], ДанныеЗапроса[ИмяРеквизита + "Язык1"]) <> 0  Тогда
		
		Если ПустаяСтрока(ПоставляемыеСведения[ИмяЛокализуемогоРеквизита(ИмяРеквизита, СведенияОбЯзыках.Язык1)]) Тогда
			Если Не ПараметрыРегистрации.ПропускатьПустые Тогда
				Возврат Истина;
			КонецЕсли;
		Иначе
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СведенияОбЯзыках.Язык2)
		И СтрСравнить(ПоставляемыеСведения[ИмяЛокализуемогоРеквизита(ИмяРеквизита, СведенияОбЯзыках.Язык2)], ДанныеЗапроса[ИмяРеквизита + "Язык2"]) <> 0  Тогда
		
		Если ПустаяСтрока(ПоставляемыеСведения[ИмяЛокализуемогоРеквизита(ИмяРеквизита, СведенияОбЯзыках.Язык2)]) Тогда
			Если Не ПараметрыРегистрации.ПропускатьПустые Тогда
				Возврат Истина;
			КонецЕсли;
		Иначе
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// Параметры:
//  ИменаРеквизитовОбъекта - Массив
//  ЛокализуемыеРеквизитыОбъекта - Соответствие
//
Процедура СформироватьИменаМультиязычныхРеквизитов(Знач ИменаРеквизитовОбъекта, Знач ЛокализуемыеРеквизитыОбъекта) Экспорт
	
	СведенияОбЯзыках = МультиязычностьПовтИсп.СведенияОбЯзыках();
	
	Для каждого РеквизитОбъекта Из ЛокализуемыеРеквизитыОбъекта Цикл
		
		ИменаРеквизитовОбъекта.Добавить(РеквизитОбъекта.Ключ);
		
		Если ЗначениеЗаполнено(СведенияОбЯзыках.Язык1) Тогда
			ИменаРеквизитовОбъекта.Добавить(РеквизитОбъекта.Ключ + "Язык1");
		КонецЕсли;
		Если ЗначениеЗаполнено(СведенияОбЯзыках.Язык2) Тогда
			ИменаРеквизитовОбъекта.Добавить(РеквизитОбъекта.Ключ + "Язык2");
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#Область УстаревшиеПроцедурыИФункции

Процедура ЗарегистрироватьПредопределенныеЭлементыДляОбновления(Параметры, ОбъектМетаданных = Неопределено) Экспорт
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("РежимОбновления", "МультиязычныеСтроки");
	ДополнительныеПараметры.Вставить("ПропускатьПустые", Истина);
	ДополнительныеПараметры.Вставить("СравниватьТабличныеЧасти",Ложь);
	
	ОбновлениеИнформационнойБазы.ЗарегистрироватьПредопределенныеЭлементыДляОбновления(Параметры, ОбъектМетаданных, ДополнительныеПараметры);
	
КонецПроцедуры

Процедура ЗаполнитьЭлементыНачальнымиДанными(ОбновитьМультиязычныеСтроки = Ложь) Экспорт
	
	ОбновлениеИнформационнойБазыСлужебный.НачальноеЗаполнениеПредопределенныхДанных(ОбновитьМультиязычныеСтроки);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Функция - Объект метаданных
//
// Параметры:
//  Объект - СправочникОбъект
//         - ДокументОбъект
//         - ДанныеФормыСтруктура:
//            * Ссылка - СправочникСсылка
//                     - ДокументСсылка
//                     - ПланВидовХарактеристикСсылка
//            * ИсходныйКлючЗаписи -РегистрСведенийЗапись 
// 
// Возвращаемое значение:
//  ОбъектМетаданных
//
Функция ОбъектМетаданных(Объект) Экспорт
	
	Если ТипЗнч(Объект) = Тип("ДанныеФормыСтруктура") Тогда
		Если Объект.Свойство("ИсходныйКлючЗаписи") Тогда
			ТипОбъекта = ТипЗнч(Объект.ИсходныйКлючЗаписи);
		Иначе
			ТипОбъекта = ТипЗнч(Объект.Ссылка);
		КонецЕсли;
	Иначе
		ТипОбъекта = ТипЗнч(Объект);
	КонецЕсли;
	
	ОбъектМетаданные = Метаданные.НайтиПоТипу(ТипОбъекта);
	
	Возврат ОбъектМетаданные;
	
КонецФункции

Функция ИмяЛокализуемогоРеквизита(ИмяРеквизита, КодЯзыка)
	
	Возврат ИмяРеквизита + "_" + КодЯзыка;
	
КонецФункции

// Код основного языка информационной базы
// 
// Возвращаемое значение:
//  Строка - код языка. Например, "ru".
//
Функция КодЯзыкаИнформационнойБазы()
	
	Если ЗначениеЗаполнено(Константы.ОсновнойЯзык.Получить()) Тогда
		Возврат Константы.ОсновнойЯзык.Получить();
	КонецЕсли;
	
	Возврат Метаданные.ОсновнойЯзык.КодЯзыка;
	
КонецФункции

Функция ОпределитьТипФормы(ИмяФормы) Экспорт
	
	Результат = "";
	
	ЧастиИмениФормы = СтрРазделить(ВРег(ИмяФормы), ".");
	ОсновнаяФормаСписка = ОсновнаяФормаСписка(ЧастиИмениФормы);
	ОсновнаяФормаВыбора = ОсновнаяФормаДляВыбора(ЧастиИмениФормы);
	
	НайденнаяФорма = Метаданные.НайтиПоПолномуИмени(ИмяФормы);
	
	Если ОсновнаяФормаСписка = НайденнаяФорма  Тогда
		Результат = "ОсновнаяФормаСписка";
	ИначеЕсли ОсновнаяФормаВыбора  = НайденнаяФорма Тогда
		Результат = "ОсновнаяФормаВыбора";
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииОбработчиковУстановкиПараметровСеанса.
// 
// Параметры:
//  ИменаПараметровСеанса - см. СтандартныеПодсистемыСервер.УстановкаПараметровСеанса.ИменаПараметровСеанса
//  УстановленныеПараметры - Массив из Строка - имена параметров, которые уже установлены.
//
Процедура УстановкаПараметровСеанса(Знач ИменаПараметровСеанса, УстановленныеПараметры) Экспорт
	
	Если ИменаПараметровСеанса = Неопределено
	 Или ИменаПараметровСеанса.Найти("ОсновнойЯзык") <> Неопределено Тогда
		
		ПараметрыСеанса.ОсновнойЯзык = КодЯзыкаИнформационнойБазы();
		УстановленныеПараметры.Добавить("ОсновнойЯзык");
	КонецЕсли;
	
КонецПроцедуры

Функция КодПервогоДополнительногоЯзыкаИнформационнойБазы() Экспорт
	
	Если Не ИспользуетсяПервыйДополнительныйЯзык() Тогда
		Возврат "";
	КонецЕсли;
	
	КодЯзыка = Константы.ДополнительныйЯзык1.Получить();
	Для Каждого ЯзыкиИзМетаданных Из Метаданные.Языки Цикл
		Если СтрСравнить(ЯзыкиИзМетаданных.КодЯзыка, КодЯзыка) = 0 Тогда
			Возврат КодЯзыка;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

Функция КодВторогоДополнительногоЯзыкаИнформационнойБазы() Экспорт
	
	Если Не ИспользуетсяВторойДополнительныйЯзык() Тогда
		Возврат "";
	КонецЕсли;
	
	КодЯзыка = Константы.ДополнительныйЯзык2.Получить();
	Для Каждого ЯзыкиИзМетаданных Из Метаданные.Языки Цикл
		Если СтрСравнить(ЯзыкиИзМетаданных.КодЯзыка, КодЯзыка) = 0 Тогда
			Возврат КодЯзыка;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

Функция ЛокализуемыеРеквизитыОбъектаДляТекущегоЯзыка(ОбъектМетаданных, Язык = Неопределено)
	
	СписокРеквизитов = Новый Соответствие;
	
	Если ЗначениеЗаполнено(Язык) Тогда
		ПрефиксЯзыка = Язык;
	Иначе
		ПрефиксЯзыка = СуффиксТекущегоЯзыка();
	КонецЕсли;
	
	СписокРеквизитовОбъекта = Новый Соответствие;
	ОбъектМетаданныхРеквизиты = ОбъектМетаданных.Реквизиты; //  КоллекцияОбъектовМетаданных из ОбъектМетаданныхРеквизит -
	Для Каждого Реквизит Из ОбъектМетаданныхРеквизиты Цикл
		СписокРеквизитовОбъекта.Вставить(Реквизит.Имя, Реквизит);
	КонецЦикла;
	
	ОбъектМетаданныхСтандартныеРеквизиты = ОбъектМетаданных.СтандартныеРеквизиты; // КоллекцияОбъектовМетаданных из ОписаниеСтандартногоРеквизита -
	Для Каждого Реквизит Из ОбъектМетаданныхСтандартныеРеквизиты Цикл
		СписокРеквизитовОбъекта.Вставить(Реквизит.Имя, Реквизит);
	КонецЦикла;
	
	ТекстЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 0
		|	*
		|ИЗ
		|	&ОбъектМетаданныхПолноеИмя КАК ДанныеИсточника";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ОбъектМетаданныхПолноеИмя", ОбъектМетаданных.ПолноеИмя());
	Запрос = Новый Запрос(ТекстЗапроса);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	СписокРеквизитов = Новый Соответствие;
	Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
		Если СтрЗаканчиваетсяНа(Колонка.Имя, ПрефиксЯзыка) Тогда
			Реквизит = СписокРеквизитовОбъекта.Получить(Колонка.Имя);
			Если Реквизит = Неопределено Тогда
				Реквизит = Метаданные.ОбщиеРеквизиты.Найти(Колонка.Имя);
			КонецЕсли;
			СписокРеквизитов.Вставить(Колонка.Имя, Реквизит);
			
		КонецЕсли;
	КонецЦикла;
	
	Возврат СписокРеквизитов;
	
КонецФункции

Функция НаименованияЛокализуемыхРеквизитовОбъекта(ОбъектМетаданных, Префикс = "")
	
	СписокРеквизитовОбъекта = Новый Соответствие;
	Если МультиязычныеСтрокиВРеквизитах(ОбъектМетаданных) Тогда
	
		ДлинаСуффиксаЯзыка = ДлинаСуффиксаЯзыка();
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 0
			|	*
			|ИЗ
			|	" + ОбъектМетаданных.ПолноеИмя();
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
			Если СтрЗаканчиваетсяНа(Колонка.Имя, "Язык1") Или СтрЗаканчиваетсяНа(Колонка.Имя, "Язык2") Тогда
				СписокРеквизитовОбъекта.Вставить(Префикс + Лев(Колонка.Имя, СтрДлина(Колонка.Имя) - ДлинаСуффиксаЯзыка), Истина);
			КонецЕсли;
		КонецЦикла;
	Иначе
		
		РеквизитыТабличнойЧастиПредставления = ОбъектМетаданных.ТабличныеЧасти.Представления.Реквизиты; // КоллекцияОбъектовМетаданных из ОбъектМетаданныхРеквизит - 
		Для каждого Реквизит Из РеквизитыТабличнойЧастиПредставления Цикл
			Если СтрСравнить(Реквизит.Имя, "КодЯзыка") = 0 Тогда
				Продолжить;
			КонецЕсли;
			СписокРеквизитовОбъекта.Вставить(Префикс + Реквизит.Имя, Истина);
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат СписокРеквизитовОбъекта;
	
КонецФункции

Функция ДлинаСуффиксаЯзыка()
	
	Возврат СтрДлина("Язык1");
	
КонецФункции

Функция ОсновнаяФормаСписка(ЧастиИмениФормы)
	
	Если ЧастиИмениФормы[0]= "СПРАВОЧНИК"
		Или ЧастиИмениФормы[0] = "ДОКУМЕНТ"
		Или ЧастиИмениФормы[0] = "ПЕРЕЧИСЛЕНИЕ"
		Или ЧастиИмениФормы[0] = "ПЛАНВИДОВХАРАКТЕРИСТИК"
		Или ЧастиИмениФормы[0] = "ПЛАНСЧЕТОВ"
		Или ЧастиИмениФормы[0] = "ПЛАНВИДОВРАСЧЕТА"
		Или ЧастиИмениФормы[0] = "БИЗНЕСПРОЦЕСС"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "РЕГИСТРБУХГАЛТЕРИИ"
		Или ЧастиИмениФормы[0] = "РЕГИСТРНАКОПЛЕНИЯ"
		Или ЧастиИмениФормы[0] = "РЕГИСТРРАСЧЕТА"
		Или ЧастиИмениФормы[0] = "РЕГИСТРСВЕДЕНИЙ"
		Или ЧастиИмениФормы[0] = "ПЛАНОБМЕНА" Тогда
			Возврат Метаданные.НайтиПоПолномуИмени(ЧастиИмениФормы[0] + "." + ЧастиИмениФормы[1]).ОсновнаяФормаСписка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция ОсновнаяФормаДляВыбора(ЧастиИмениФормы)
	
	Если ЧастиИмениФормы[0]= "СПРАВОЧНИК"
		Или ЧастиИмениФормы[0] = "ДОКУМЕНТ"
		Или ЧастиИмениФормы[0] = "ПЕРЕЧИСЛЕНИЕ"
		Или ЧастиИмениФормы[0] = "ПЛАНВИДОВХАРАКТЕРИСТИК"
		Или ЧастиИмениФормы[0] = "ПЛАНСЧЕТОВ"
		Или ЧастиИмениФормы[0] = "БИЗНЕСПРОЦЕСС"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "ЗАДАЧА"
		Или ЧастиИмениФормы[0] = "ПЛАНОБМЕНА" Тогда
			Возврат Метаданные.НайтиПоПолномуИмени(ЧастиИмениФормы[0] + "." + ЧастиИмениФормы[1]).ОсновнаяФормаДляВыбора;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Процедура ПерезаполнитьМультиязычныеСтрокиВОбъектах(Параметры, Адрес) Экспорт
	ОбновлениеИнформационнойБазыСлужебный.НачальноеЗаполнениеПредопределенныхДанных(Истина);
КонецПроцедуры

Функция ЭтоОсновнойЯзык() Экспорт
	
	Возврат СтрСравнить(ОбщегоНазначения.КодОсновногоЯзыка(), ТекущийЯзык().КодЯзыка) = 0;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Начальное заполнение элементов данными.

// Параметры:
//  Реквизит - ОбъектМетаданныхРеквизит
//           - ОписаниеСтандартногоРеквизита
//
Функция ЭтоЛокализуемыйРеквизит(ИмяРеквизита)
	Возврат СтрЗаканчиваетсяНа(ИмяРеквизита, "Язык1") Или СтрЗаканчиваетсяНа(ИмяРеквизита, "Язык2");
КонецФункции

Функция СтрокаВВидеНСтр(ПроверяемаяСтрока) Экспорт
	
	ВариантыСовпадений = Новый Массив;
	Для каждого Язык Из Метаданные.Языки Цикл
		ВариантыСовпадений.Добавить(Язык.КодЯзыка + "=");
	КонецЦикла;
	
	Для каждого ВариантСовпадения Из ВариантыСовпадений Цикл
		Если СтрНайти(ПроверяемаяСтрока, ВариантСовпадения) > 0 Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти