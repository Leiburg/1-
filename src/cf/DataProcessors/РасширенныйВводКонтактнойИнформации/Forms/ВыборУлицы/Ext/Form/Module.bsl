﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Параметры формы:
//     Уровень                           - Число  - Запрашиваемый уровень.
//     Родитель                          - УникальныйИдентификатор - Родительский объект.
//     СкрыватьНеактуальныеАдреса        - Булево - флаг того, что при неактуальные адреса будут скрываться.
//     ФорматАдреса - Строка - вариант классификатора.
//     Идентификатор                     - УникальныйИдентификатор - Текущий адресный элемент.
//     Представление                     - Строка - Представление текущего элемента,. используется если не указан
//                                                  Идентификатор.
//
// Результат выбора:
//     Структура - с полями
//         * Отказ                      - Булево - флаг того, что при обработке произошла ошибка.
//         * КраткоеПредставлениеОшибки - Строка - Описание ошибки.
//         * Идентификатор              - УникальныйИдентификатор - Данные адреса.
//         * Представление              - Строка                  - Данные адреса.
//         * РегионЗагружен             - Булево                  - Имеет смысл только для регионов, Истина, если есть
//                                                                  записи.
// ---------------------------------------------------------------------------------------------------------------------
//

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("Родитель", Родитель);
	Параметры.Свойство("ТипАдреса", ТипАдреса);
	
	ПараметрыПоиска = Новый Структура;
	Уровень = 7;
	
	ДанныеКлассификатора = Обработки.РасширенныйВводКонтактнойИнформации.АдресаДляИнтерактивногоВыбора(Родитель, Уровень, ТипАдреса, ПараметрыПоиска);
	
	ВариантыАдреса.Загрузить(ДанныеКлассификатора.Данные);
	НаселенныйПунктДетально = Параметры.НаселенныйПунктДетально;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		
		Элементы.Переместить(Элементы.ВариантыАдресаНайти, Элементы.ФормаКоманднаяПанель);
		Элементы.Переместить(Элементы.ВариантыАдресаОтменитьПоиск, Элементы.ФормаКоманднаяПанель);
		Элементы.Переместить(Элементы.ФормаСправка, Элементы.ФормаКоманднаяПанель);
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Выбрать", "Видимость", Ложь);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Найти", "ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Авто);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НайтиАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	Если Ожидание = 0 Тогда
		// Формирование списка быстрого выбора, стандартную обработку не надо трогать.
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Текст) Тогда
		
		РаботаСАдресамиКлиент.ПреобразоватьВводАдреса(Текст);
		Элементы.ВариантыАдреса.ОтборСтрок = Новый ФиксированнаяСтруктура("Представление", Текст);
		
	Иначе
		Элементы.ВариантыАдреса.ОтборСтрок = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВариантыАдресаВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	
	ПроизвестиВыбор(Значение);
	
КонецПроцедуры

&НаКлиенте
Процедура НайтиОчистка(Элемент, СтандартнаяОбработка)
	Элементы.ВариантыАдреса.ОтборСтрок = Неопределено;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Выбрать(Команда)
	ПроизвестиВыбор(Элементы.ВариантыАдреса.ТекущаяСтрока);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПроизвестиВыбор(Знач НомерСтроки)
	
	Если НомерСтроки = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Данные = ВариантыАдреса.НайтиПоИдентификатору(НомерСтроки);
	
	Если Данные = Неопределено Тогда
		Возврат;
	ИначеЕсли Не Данные.Неактуален Тогда
		Результат = Новый Структура();
		Результат.Вставить("Идентификатор", Данные.Идентификатор);
		Результат.Вставить("Муниципальный", РаботаСАдресамиКлиентСервер.ЭтоМуниципальныйАдрес(ТипАдреса));
		Закрыть(Результат);
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
