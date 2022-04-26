﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ЭлементСпискаДоНачалаИзменения; // см. ЭлементСпискаДоНачалаИзменения

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ОграничиватьВыборУказаннымиЗначениями", ОграничиватьВыборУказаннымиЗначениями);
	БыстрыйВыбор = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "БыстрыйВыбор", Ложь);
	
	ИнформацияОТипах = ОтчетыСервер.РасширенноеОписаниеТипов(Параметры.ОписаниеТипов, Истина);
	ИнформацияОТипах.Вставить("СодержитСсылочныеТипы", Ложь);
	
	ВсеТипыСБыстрымВыбором = ИнформацияОТипах.КоличествоТипов < 10
		И (ИнформацияОТипах.КоличествоТипов = ИнформацияОТипах.ОбъектныеТипы.Количество());
	Для Каждого Тип Из ИнформацияОТипах.ОбъектныеТипы Цикл
		ОбъектМетаданных = Метаданные.НайтиПоТипу(Тип);
		Если ОбъектМетаданных = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ИнформацияОТипах.СодержитСсылочныеТипы = Истина;
		
		Вид = ВРег(СтрРазделить(ОбъектМетаданных.ПолноеИмя(), ".")[0]);
		Если Вид <> "ПЕРЕЧИСЛЕНИЕ" Тогда
			Если Вид = "СПРАВОЧНИК"
				Или Вид = "ПЛАНВИДОВРАСЧЕТА"
				Или Вид = "ПЛАНВИДОВХАРАКТЕРИСТИК"
				Или Вид = "ПЛАНОБМЕНА"
				Или Вид = "ПЛАНСЧЕТОВ" Тогда
				Если ОбъектМетаданных.СпособВыбора <> Метаданные.СвойстваОбъектов.СпособВыбора.БыстрыйВыбор Тогда
					ВсеТипыСБыстрымВыбором = Ложь;
				КонецЕсли;
			Иначе
				ВсеТипыСБыстрымВыбором = Ложь;
			КонецЕсли;
		КонецЕсли;
		
		Если Не ВсеТипыСБыстрымВыбором Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	ЗначенияДляВыбора = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ЗначенияДляВыбора");
	Отмеченные = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "Отмеченные");
	
	Если ВсеТипыСБыстрымВыбором Тогда
		БыстрыйВыбор = Истина;
	КонецЕсли;
	
	Если Не ОграничиватьВыборУказаннымиЗначениями И БыстрыйВыбор И Не Параметры.ЗначенияДляВыбораЗаполнены Тогда
		ЗначенияДляВыбора = ОтчетыСервер.ЗначенияДляВыбора(Параметры);
	КонецЕсли;
	
	Заголовок = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "Представление");
	Если ПустаяСтрока(Заголовок) Тогда
		Заголовок = Строка(Параметры.ОписаниеТипов);
	КонецЕсли;
	
	Если ИнформацияОТипах.КоличествоТипов = 0 Тогда
		ОграничиватьВыборУказаннымиЗначениями = Истина;
	ИначеЕсли Не ИнформацияОТипах.СодержитОбъектныеТипы Или БыстрыйВыбор Тогда
		Элементы.СписокПодбор.Видимость       = Ложь;
		Элементы.СписокПодборМеню.Видимость   = Ложь;
		Элементы.СписокПодборПодвал.Видимость = Ложь;
		Элементы.СписокДобавить.ТолькоВоВсехДействиях = Ложь;
	КонецЕсли;
	
	ВыборГруппИЭлементов = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ВыборГруппИЭлементов");
	Элементы.СписокЗначение.ВыборГруппИЭлементов = ОтчетыКлиентСервер.ЗначениеТипаГруппыИЭлементы(ВыборГруппИЭлементов);
	
	Список.ТипЗначения = ИнформацияОТипах.ОписаниеТиповДляФормы;
	Если ТипЗнч(ЗначенияДляВыбора) = Тип("СписокЗначений") Тогда
		ЗначенияДляВыбора.ЗаполнитьПометки(Ложь);
		ОтчетыКлиентСервер.ДополнитьСписок(Список, ЗначенияДляВыбора, Истина, Истина);
	КонецЕсли;
	Если ТипЗнч(Отмеченные) = Тип("СписокЗначений") Тогда
		Отмеченные.ЗаполнитьПометки(Истина);
		ОтчетыКлиентСервер.ДополнитьСписок(Список, Отмеченные, Истина, Не ОграничиватьВыборУказаннымиЗначениями);
	КонецЕсли;
	
	Если Список.Количество() = 0 Тогда
		Элементы.СписокПодборПодвал.Видимость = Ложь;
	КонецЕсли;
	
	Если ОграничиватьВыборУказаннымиЗначениями Тогда
		Элементы.СписокЗначение.ТолькоПросмотр = Истина;
		Элементы.Список.ИзменятьСоставСтрок    = Ложь;
		
		Элементы.СписокДобавлениеУдаление.Видимость     = Ложь;
		Элементы.СписокДобавлениеУдалениеМеню.Видимость = Ложь;
		
		Элементы.СписокСортировка.Видимость     = Ложь;
		Элементы.СписокСортировкаМеню.Видимость = Ложь;
		
		Элементы.СписокПеремещение.Видимость     = Ложь;
		Элементы.СписокПеремещениеМеню.Видимость = Ложь;
		
		Элементы.СписокПодборПодвал.Видимость = Ложь;
	КонецЕсли;
	
	ПараметрыВыбора = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "ПараметрыВыбора");
	Если ТипЗнч(ПараметрыВыбора) = Тип("Массив") Тогда
		Элементы.СписокЗначение.ПараметрыВыбора = Новый ФиксированныйМассив(ПараметрыВыбора);
	КонецЕсли;
	
	КлючСохраненияПоложенияОкна = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Параметры, "КлючУникальности");
	Если ПустаяСтрока(КлючСохраненияПоложенияОкна) Тогда
		КлючСохраненияПоложенияОкна = ОбщегоНазначения.СократитьСтрокуКонтрольнойСуммой(Строка(Список.ТипЗначения), 128);
	КонецЕсли;
	
	Если ОграничиватьВыборУказаннымиЗначениями
		Или Не ИнформацияОТипах.СодержитСсылочныеТипы
		Или Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗагрузкаДанныхИзФайла") Тогда
			Элементы.СписокВставитьИзБуфераОбмена.Видимость     = Ложь;
			Элементы.СписокВставитьИзБуфераОбменаМеню.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокПередНачаломИзменения(Элемент, Отказ)
	СтрокаИдентификатор = Элемент.ТекущаяСтрока;
	Если СтрокаИдентификатор = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СписокЗначенийВФорме = ЭтотОбъект[Элемент.Имя];
	ЭлементСпискаВФорме = СписокЗначенийВФорме.НайтиПоИдентификатору(СтрокаИдентификатор);
	
	ТекущаяСтрока = Элемент.ТекущиеДанные;
	Если ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ЭлементСпискаДоНачалаИзменения = ЭлементСпискаДоНачалаИзменения();
	ЗаполнитьЗначенияСвойств(ЭлементСпискаДоНачалаИзменения, ЭлементСпискаВФорме);
	ЭлементСпискаДоНачалаИзменения.Идентификатор = СтрокаИдентификатор;
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Если ОграничиватьВыборУказаннымиЗначениями Тогда
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокПередУдалением(Элемент, Отказ)
	Если ОграничиватьВыборУказаннымиЗначениями Тогда
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаНачалаРедактирования, ОтменаЗавершенияРедактирования)
	Если ОтменаНачалаРедактирования Тогда
		Возврат;
	КонецЕсли;
	
	СтрокаИдентификатор = Элемент.ТекущаяСтрока;
	Если СтрокаИдентификатор = Неопределено Тогда
		Возврат;
	КонецЕсли;
	СписокЗначенийВФорме = ЭтотОбъект[Элемент.Имя];
	ЭлементСпискаВФорме = СписокЗначенийВФорме.НайтиПоИдентификатору(СтрокаИдентификатор);
	
	Значение = ЭлементСпискаВФорме.Значение;
	
	Для Каждого ЭлементСпискаДубльВФорме Из СписокЗначенийВФорме Цикл
		Если ЭлементСпискаДубльВФорме.Значение = Значение И ЭлементСпискаДубльВФорме <> ЭлементСпискаВФорме Тогда
			ОтменаЗавершенияРедактирования = Истина; // Запрет дублей.
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	ЕстьИнформация = (ЭлементСпискаДоНачалаИзменения <> Неопределено И ЭлементСпискаДоНачалаИзменения.Идентификатор = СтрокаИдентификатор);
	Если Не ОтменаЗавершенияРедактирования И ЕстьИнформация И ЭлементСпискаДоНачалаИзменения.Значение <> Значение Тогда
		Если ОграничиватьВыборУказаннымиЗначениями Тогда
			ОтменаЗавершенияРедактирования = Истина;
		Иначе
			ЭлементСпискаВФорме.Представление = ""; // Автозаполнение представления.
			ЭлементСпискаВФорме.Пометка = Истина; // Включение флажка.
		КонецЕсли;
	КонецЕсли;
	
	Если ОтменаЗавершенияРедактирования Тогда
		// Откат значений.
		Если ЕстьИнформация Тогда
			ЗаполнитьЗначенияСвойств(ЭлементСпискаВФорме, ЭлементСпискаДоНачалаИзменения);
		КонецЕсли;
		// Перезапуск события "ПередОкончаниемРедактирования" с ОтменаНачалаРедактирования = Истина.
		Элемент.ЗакончитьРедактированиеСтроки(Истина);
	Иначе
		Если НоваяСтрока Тогда
			ЭлементСпискаВФорме.Пометка = Истина; // Включение флажка.
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СписокОбработкаВыбора(Элемент, РезультатВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Выбранные = ОтчетыКлиентСервер.ЗначенияСписком(РезультатВыбора);
	Выбранные.ЗаполнитьПометки(Истина);
	
	Дополнение = ОтчетыКлиентСервер.ДополнитьСписок(Список, Выбранные, Истина, Истина);
	Если Дополнение.Всего = 0 Тогда
		Возврат;
	КонецЕсли;
	Если Дополнение.Всего = 1 Тогда
		ЗаголовокОповещения = НСтр("ru = 'Элемент добавлен в список'");
	Иначе
		ЗаголовокОповещения = НСтр("ru = 'Элементы добавлены в список'");
	КонецЕсли;
	ПоказатьОповещениеПользователя(
		ЗаголовокОповещения,
		,
		Строка(Выбранные),
		БиблиотекаКартинок.ВыполнитьЗадачу);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗавершитьРедактирование(Команда)
	Если МодальныйРежим
		Или РежимОткрытияОкна = РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс
		Или ВладелецФормы = Неопределено Тогда
		Закрыть(Список);
	Иначе
		ОповеститьОВыборе(Список);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВставитьИзБуфераОбмена(Команда)
	ПараметрыПоиска = Новый Структура;
	ПараметрыПоиска.Вставить("ОписаниеТипов", Список.ТипЗначения);
	ПараметрыПоиска.Вставить("ПараметрыВыбора", Элементы.СписокЗначение.ПараметрыВыбора);
	ПараметрыПоиска.Вставить("ПредставлениеПоля", Заголовок);
	ПараметрыПоиска.Вставить("Сценарий", "ПоискСсылок");
	
	ПараметрыВыполнения = Новый Структура;
	Обработчик = Новый ОписаниеОповещения("ВставитьИзБуфераОбменаЗавершение", ЭтотОбъект, ПараметрыВыполнения);
	
	МодульЗагрузкаДанныхИзФайлаКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ЗагрузкаДанныхИзФайлаКлиент");
	МодульЗагрузкаДанныхИзФайлаКлиент.ПоказатьФормуЗаполненияСсылок(ПараметрыПоиска, Обработчик);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВставитьИзБуфераОбменаЗавершение(НайденныеОбъекты, ПараметрыВыполнения) Экспорт
	
	Если НайденныеОбъекты = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Значение Из НайденныеОбъекты Цикл
		ОтчетыКлиентСервер.ДобавитьУникальноеЗначениеВСписок(Список, Значение, Неопределено, Истина);
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Конструкторы.

// Конструктор описания свойств элемента списка значений.
//
//  Возвращаемое значение:
//   Структура - описание свойств элемента списка значений, где:
//       * Идентификатор - Число
//       * Пометка - Булево
//       * Значение - Неопределено
//       * Представление - Строка
//
&НаКлиенте
Функция ЭлементСпискаДоНачалаИзменения()
	
	Элемент = Новый Структура();
	Элемент.Вставить("Идентификатор", 0);
	Элемент.Вставить("Пометка", Ложь);
	Элемент.Вставить("Значение", Неопределено);
	Элемент.Вставить("Представление", "");
	
	Возврат Элемент;
	
КонецФункции

#КонецОбласти