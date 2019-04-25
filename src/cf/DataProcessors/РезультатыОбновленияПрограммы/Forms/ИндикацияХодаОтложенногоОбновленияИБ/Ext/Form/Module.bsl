﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкиПодсистемы = ОбновлениеИнформационнойБазыСлужебный.НастройкиПодсистемы();
	ТекстПодсказки      = НастройкиПодсистемы.ПоясненияДляРезультатовОбновления;
	
	Если Не ПустаяСтрока(ТекстПодсказки) Тогда
		Элементы.ПодсказкаГдеНайтиЭтуФорму.Заголовок = ТекстПодсказки;
	КонецЕсли;
	
	Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		
		Элементы.ГруппаПодсказкаПроПериодНаименьшейАктивностиПользователей.Видимость = Ложь;
		Элементы.ПодсказкаГдеНайтиЭтуФорму.Заголовок = 
			НСтр("ru = 'Ход обработки данных версии программы можно также проконтролировать из раздела
		               |""Информация"" на рабочем столе, команда ""Описание изменений программы"".'");
		
	КонецЕсли;
	
	// Зачитываем значение констант.
	ПолучитьКоличествоПотоковОбновленияИнформационнойБазы();
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ПриоритетОбновления = ?(СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Свойство("ФорсироватьОбновление"), "ОбработкаДанных", "РаботаПользователей");
	ВремяОкончанияОбновления = СведенияОбОбновлении.ВремяОкончанияОбновления;
	
	ВремяНачалаОтложенногоОбновления = СведенияОбОбновлении.ВремяНачалаОтложенногоОбновления;
	ВремяОкончаниеОтложенногоОбновления = СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления;
	
	ИБФайловая = ОбщегоНазначения.ИнформационнаяБазаФайловая();
	
	Если ЗначениеЗаполнено(ВремяОкончанияОбновления) Тогда
		Элементы.ИнформацияОбновлениеЗавершено.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			Элементы.ИнформацияОбновлениеЗавершено.Заголовок,
			Метаданные.Версия,
			Формат(ВремяОкончанияОбновления, "ДЛФ=D"),
			Формат(ВремяОкончанияОбновления, "ДЛФ=T"),
			СведенияОбОбновлении.ПродолжительностьОбновления);
	Иначе
		ЗаголовокОбновлениеЗавершено = НСтр("ru = 'Версия программы успешно обновлена на версию %1'");
		Элементы.ИнформацияОбновлениеЗавершено.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ЗаголовокОбновлениеЗавершено, Метаданные.Версия);
	КонецЕсли;
	
	Если СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления = Неопределено Тогда
		
		Если Не Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.СтатусОбновленияДляПользователя;
		Иначе
			
			Если Не ИБФайловая И СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено Тогда
				Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВыполняется;
			Иначе
				Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВФайловойБазе;
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		ТекстСообщения = СообщениеОРезультатахОбновления(СведенияОбОбновлении);
		Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
		
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		ШаблонЗаголовка = НСтр("ru = 'Дополнительные процедуры обработки данных завершены %1 в %2'");
		Элементы.ИнформацияОтложенноеОбновлениеЗавершено.Заголовок = 
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, 
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=D"),
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=T"));
		
	КонецЕсли;
	
	УстановитьВидимостьКоличестваПотоковОбновленияИнформационнойБазы();
	
	Если Не ИБФайловая Тогда
		ОбновлениеЗавершено = Ложь;
		ОбновитьИнформациюОХодеОбновления(СведенияОбОбновлении, ОбновлениеЗавершено);
		УстановитьДоступностьКоличестваПотоковОбновленияИнформационнойБазы(ЭтотОбъект);
		
		Если ОбновлениеЗавершено Тогда
			ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении);
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
			Возврат;
		КонецЕсли;
		
	Иначе
		Элементы.ИнформацияСтатусОбновления.Видимость = Ложь;
		Элементы.ИзменитьРасписание.Видимость         = Ложь;
	КонецЕсли;
	
	Если Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		
		Если ОбщегоНазначения.РазделениеВключено() Тогда
			Элементы.ГруппаНастройкаРасписания.Видимость = Ложь;
		Иначе
			ОтборЗаданий = Новый Структура;
			ОтборЗаданий.Вставить("Метаданные", Метаданные.РегламентныеЗадания.ОтложенноеОбновлениеИБ);
			Задания = РегламентныеЗаданияСервер.НайтиЗадания(ОтборЗаданий);
			Для Каждого Задание Из Задания Цикл
				Расписание = Задание.Расписание;
				Прервать;
			КонецЦикла;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Элементы.ГиперссылкаОсновноеОбновление.Видимость = Ложь;
		Элементы.ГруппаПриоритет.Видимость               = Ложь;
	КонецЕсли;
	
	ОбработатьРезультатОбновленияНаСервере();
	
	СкрытьЛишниеГруппыНаФорме(Параметры.ОткрытиеИзПанелиАдминистрирования);
	
	Элементы.ОткрытьСписокОтложенныхОбработчиков.Заголовок = ТекстСообщения;
	Элементы.ЗаголовокИнформации.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выполняются дополнительные процедуры обработки данных на версию %1
			|Работа с этими данными временно ограничена'"), Метаданные.Версия);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
#Если МобильныйКлиент Тогда
	ЭтотОбъект.ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Нет;
#КонецЕсли
	
	Если Не ИБФайловая Тогда
		ПодключитьОбработчикОжидания("ПроверитьСтатусВыполненияОбработчиков", 15);
	КонецЕсли;
	
	ОбработатьРезультатОбновленияНаКлиенте();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ОтложенноеОбновление" Тогда
		
		Если Не ИБФайловая Тогда
			Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВыполняется;
		КонецЕсли;
		
		ПодключитьОбработчикОжидания("ЗапуститьОтложенноеОбновление", 0.5, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияСтатусОбновленияНажатие(Элемент)
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ОтложенныеОбработчики");
КонецПроцедуры

&НаКлиенте
Процедура ГиперссылкаОсновноеОбновлениеНажатие(Элемент)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ДатаНачала", ВремяНачалаОтложенногоОбновления);
	Если ВремяОкончаниеОтложенногоОбновления <> Неопределено Тогда
		ПараметрыФормы.Вставить("ДатаОкончания", ВремяОкончаниеОтложенногоОбновления);
	КонецЕсли;
	
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияОшибкаОбновленияОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыФормы = Новый Структура;
	
	СписокПриложений = Новый Массив;
	СписокПриложений.Добавить("COMConnection");
	СписокПриложений.Добавить("Designer");
	СписокПриложений.Добавить("1CV8");
	СписокПриложений.Добавить("1CV8C");
	
	ПараметрыФормы.Вставить("Пользователь", ИмяПользователя());
	ПараметрыФормы.Вставить("ИмяПриложения", СписокПриложений);
	
	ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриоритетОбновленияПриИзменении(Элемент)
	
	УстановитьПриоритетОбновления();
	УстановитьДоступностьКоличестваПотоковОбновленияИнформационнойБазы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура КоличествоПотоковОбновленияИнформационнойБазыПриИзменении(Элемент)
	
	УстановитьКоличествоПотоковОбновленияИнформационнойБазы();
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияИсправленияУстановленыОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПоказатьУстановленныеИсправления();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыполнитьОбновление(Команда)
	
	Если Не ИБФайловая Тогда
		Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеВыполняется;
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("ЗапуститьОтложенноеОбновление", 0.5, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьСписокОтложенныхОбработчиков(Команда)
	ОткрытьФорму("Обработка.РезультатыОбновленияПрограммы.Форма.ОтложенныеОбработчики");
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписание(Команда)
	
	Диалог = Новый ДиалогРасписанияРегламентногоЗадания(Расписание);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ИзменитьРасписаниеПослеУстановкиРасписания", ЭтотОбъект);
	Диалог.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьБлокировкуРегламентныхЗаданий(Команда)
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
		МодульСоединенияИБКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("СоединенияИБКлиент");
		МодульСоединенияИБКлиент.ПриОткрытииФормыБлокировкиРаботыПользователей();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияДляТехническойПоддержки(Команда)
	
	Если Не ПустаяСтрока(КаталогСкрипта) Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("НачатьПоискФайловЗавершение", ЭтотОбъект);
		НачатьПоискФайлов(ОписаниеОповещения, КаталогСкрипта, "log*.txt");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьПоискФайловЗавершение(МассивФайлов, ДополнительныеПараметры) Экспорт
	Если МассивФайлов.Количество() > 0 Тогда
		ФайлЖурнала = МассивФайлов[0];
		ФайловаяСистемаКлиент.ОткрытьФайл(ФайлЖурнала.ПолноеИмя);
	Иначе
		// Если лога нет, то открываем временный каталог скрипта обновления.
		ФайловаяСистемаКлиент.ОткрытьПроводник(КаталогСкрипта);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СкрытьЛишниеГруппыНаФорме(ОткрытиеИзПанелиАдминистрирования)
	
	ЭтоПолноправныйПользователь = Пользователи.ЭтоПолноправныйПользователь(, Истина);
	
	Если Не ЭтоПолноправныйПользователь Или ОткрытиеИзПанелиАдминистрирования Тогда
		КлючСохраненияПоложенияОкна = "ФормаДляОбычногоПользователя";
		
		Элементы.ПодсказкаГдеНайтиЭтуФорму.Видимость = Ложь;
		Элементы.ГиперссылкаОсновноеОбновление.Видимость = ПравоДоступа("Просмотр", Метаданные.Обработки.ЖурналРегистрации);
		
	Иначе
		КлючСохраненияПоложенияОкна = "ФормаДляАдминистратора";
	КонецЕсли;
	
	Элементы.СнятьБлокировкуРегламентныхЗаданий.Видимость = ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей");
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПриоритетОбновления()
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		Блокировка.Добавить("Константа.СведенияОбОбновленииИБ");
		Блокировка.Заблокировать();
		
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		Если ПриоритетОбновления = "ОбработкаДанных" Тогда
			СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Вставить("ФорсироватьОбновление");
		Иначе
			СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Удалить("ФорсироватьОбновление");
		КонецЕсли;
		
		ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьКоличествоПотоковОбновленияИнформационнойБазы()
	
	Константы.КоличествоПотоковОбновленияИнформационнойБазы.Установить(КоличествоПотоковОбновленияИнформационнойБазы);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьОтложенноеОбновление()
	
	ВыполнитьОбновлениеНаСервере();
	Если Не ИБФайловая Тогда
		ПодключитьОбработчикОжидания("ПроверитьСтатусВыполненияОбработчиков", 15);
		Возврат;
	КонецЕсли;
	
	Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьСтатусВыполненияОбработчиков()
	
	ОбновлениеЗавершено = Ложь;
	ПроверитьСтатусВыполненияОбработчиковНаСервере(ОбновлениеЗавершено);
	Если ОбновлениеЗавершено Тогда
		Элементы.СтатусОбновления.ТекущаяСтраница = Элементы.ОбновлениеЗавершено;
		ОтключитьОбработчикОжидания("ПроверитьСтатусВыполненияОбработчиков")
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьСтатусВыполненияОбработчиковНаСервере(ОбновлениеЗавершено)
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	Если СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления <> Неопределено Тогда
		ОбновлениеЗавершено = Истина;
	Иначе
		ОбновитьИнформациюОХодеОбновления(СведенияОбОбновлении, ОбновлениеЗавершено);
	КонецЕсли;
	
	Если ОбновлениеЗавершено = Истина Тогда
		ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьОбновлениеНаСервере()
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	
	СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено;
	СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления = Неопределено;
	Для Каждого СтрокаДереваБиблиотека Из СведенияОбОбновлении.ДеревоОбработчиков.Строки Цикл
		Для Каждого СтрокаДереваВерсия Из СтрокаДереваБиблиотека.Строки Цикл
			Для Каждого Обработчик Из СтрокаДереваВерсия.Строки Цикл
				Обработчик.ЧислоПопыток = 0;
				Если Обработчик.Статус = "Ошибка" Тогда
					Обработчик.СтатистикаВыполнения.Очистить();
					Обработчик.Статус = "НеВыполнено";
				ИначеЕсли Обработчик.Статус = "Выполняется" Тогда
					Обработчик.СтатистикаВыполнения.Вставить("КоличествоЗапусков", 0);
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	ПланОбновленияПуст = Истина;
	Для Каждого ЦиклОбновления Из СведенияОбОбновлении.ПланОтложенногоОбновления Цикл
		Если ЦиклОбновления.Свойство("ЗавершеноСОшибками") Тогда
			ЦиклОбновления.Удалить("ЗавершеноСОшибками");
		КонецЕсли;
		Если ЦиклОбновления.Обработчики.Количество() > 0 Тогда
			ПланОбновленияПуст = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Если ПланОбновленияПуст Тогда
		ОбновлениеИнформационнойБазыСлужебный.СоставитьПланОтложенногоОбновления(СведенияОбОбновлении, Истина);
	КонецЕсли;
	
	ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
	
	Если Не ИБФайловая Тогда
		ОбновлениеИнформационнойБазыСлужебный.ПриВключенииОтложенногоОбновления(Истина);
		Возврат;
	КонецЕсли;
	
	ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОтложенноеОбновлениеСейчас(Неопределено);
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСтраницуОбновлениеЗавершено(СведенияОбОбновлении)
	
	ШаблонЗаголовка = НСтр("ru = 'Дополнительные процедуры обработки данных завершены %1 в %2'");
	ТекстСообщения = СообщениеОРезультатахОбновления(СведенияОбОбновлении);
	
	Элементы.ИнформацияОтложенноеОбновлениеЗавершено.Заголовок = 
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗаголовка, 
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=D"),
			Формат(СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления, "ДЛФ=T"));
	
	Элементы.ОткрытьСписокОтложенныхОбработчиков.Заголовок = ТекстСообщения;
	
	ВремяОкончаниеОтложенногоОбновления = СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления;
	
КонецПроцедуры

&НаСервере
Функция СообщениеОРезультатахОбновления(СведенияОбОбновлении)
	
	УспешноВыполненоОбработчиков = 0;
	ВсегоОбработчиков            = 0;
	Для Каждого СтрокаДереваБиблиотека Из СведенияОбОбновлении.ДеревоОбработчиков.Строки Цикл
		Для Каждого СтрокаДереваВерсия Из СтрокаДереваБиблиотека.Строки Цикл
			ВсегоОбработчиков = ВсегоОбработчиков + СтрокаДереваВерсия.Строки.Количество();
			Для Каждого Обработчик Из СтрокаДереваВерсия.Строки Цикл
				
				Если Обработчик.Статус = "Выполнено" Тогда
					УспешноВыполненоОбработчиков = УспешноВыполненоОбработчиков + 1;
				КонецЕсли;
				
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Если ВсегоОбработчиков = УспешноВыполненоОбработчиков Тогда
		
		Если ВсегоОбработчиков = 0 Тогда
			Элементы.ИнформацияОтложенныеОбработчикиОтсутствуют.Видимость = Истина;
			Элементы.ГруппаПереходКСпискуОтложенныхОбработчиков.Видимость = Ложь;
			ТекстСообщения = "";
		Иначе
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Все процедуры обновления выполнены успешно (%1)'"), УспешноВыполненоОбработчиков);
		КонецЕсли;
		Элементы.КартинкаЗавершено.Картинка = БиблиотекаКартинок.Успешно32;
	Иначе
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Не все процедуры удалось выполнить (выполнено %1 из %2)'"), 
			УспешноВыполненоОбработчиков, ВсегоОбработчиков);
		Элементы.КартинкаЗавершено.Картинка = БиблиотекаКартинок.Ошибка32;
	КонецЕсли;
	Возврат ТекстСообщения;
	
КонецФункции

&НаСервере
Процедура ОбновитьИнформациюОХодеОбновления(СведенияОбОбновлении, ОбновлениеЗавершено = Ложь)
	
	ВыполненоОбработчиков = 0;
	ВсегоОбработчиков     = 0;
	Для Каждого СтрокаДереваБиблиотека Из СведенияОбОбновлении.ДеревоОбработчиков.Строки Цикл
		Для Каждого СтрокаДереваВерсия Из СтрокаДереваБиблиотека.Строки Цикл
			ВсегоОбработчиков = ВсегоОбработчиков + СтрокаДереваВерсия.Строки.Количество();
			Для Каждого Обработчик Из СтрокаДереваВерсия.Строки Цикл
				
				Если Обработчик.Статус = "Выполнено" Тогда
					ВыполненоОбработчиков = ВыполненоОбработчиков + 1;
				КонецЕсли;
				
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Если ВсегоОбработчиков = 0 Тогда
		ОбновлениеЗавершено = Истина;
	КонецЕсли;
	
	Элементы.ИнформацияСтатусОбновления.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Выполнено: %1 из %2'"),
		ВыполненоОбработчиков,
		ВсегоОбработчиков);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьРасписаниеОтложенногоОбновления(НовоеРасписание)
	
	ОтборЗаданий = Новый Структура;
	ОтборЗаданий.Вставить("Метаданные", Метаданные.РегламентныеЗадания.ОтложенноеОбновлениеИБ);
	Задания = РегламентныеЗаданияСервер.НайтиЗадания(ОтборЗаданий);
	
	Для Каждого Задание Из Задания Цикл
		ПараметрыЗадания = Новый Структура("Расписание", НовоеРасписание);
		РегламентныеЗаданияСервер.ИзменитьЗадание(Задание, ПараметрыЗадания);
	КонецЦикла;
	
	Расписание = НовоеРасписание;
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписаниеПослеУстановкиРасписания(НовоеРасписание, ДополнительныеПараметры) Экспорт
	
	Если НовоеРасписание <> Неопределено Тогда
		Если НовоеРасписание.ПериодПовтораВТечениеДня = 0 Тогда
			Оповещение = Новый ОписаниеОповещения("ИзменитьРасписаниеПослеВопроса", ЭтотОбъект, НовоеРасписание);
			
			КнопкиВопроса = Новый СписокЗначений;
			КнопкиВопроса.Добавить("НастроитьРасписание", НСтр("ru = 'Настроить расписание'"));
			КнопкиВопроса.Добавить("РекомендуемыеНастройки", НСтр("ru = 'Установить рекомендуемые настройки'"));
			
			ТекстСообщения = НСтр("ru = 'Дополнительные процедуры обработки данных выполняются небольшими порциями,
				|поэтому для их корректной работы необходимо обязательно задать интервал повтора после завершения.
				|
				|Для этого в окне настройки расписания необходимо перейти на вкладку ""Дневное""
				|и заполнить поле ""Повторять через"".'");
			ПоказатьВопрос(Оповещение, ТекстСообщения, КнопкиВопроса,, "НастроитьРасписание");
		Иначе
			УстановитьРасписаниеОтложенногоОбновления(НовоеРасписание);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписаниеПослеВопроса(Результат, НовоеРасписание) Экспорт
	
	Если Результат = "РекомендуемыеНастройки" Тогда
		НовоеРасписание.ПериодПовтораВТечениеДня = 60;
		НовоеРасписание.ПаузаПовтора = 60;
		УстановитьРасписаниеОтложенногоОбновления(НовоеРасписание);
	Иначе
		ОписаниеОповещения = Новый ОписаниеОповещения("ИзменитьРасписаниеПослеУстановкиРасписания", ЭтотОбъект);
		Диалог = Новый ДиалогРасписанияРегламентногоЗадания(НовоеРасписание);
		Диалог.Показать(ОписаниеОповещения);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьРезультатОбновленияНаСервере()
	
	Элементы.ГруппаУстановленныеИсправления.Видимость = Ложь;
	// Если это первый запуск после обновления конфигурации, то запоминаем и сбрасываем статус.
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		ИнформацияПоИсправлениям = Неопределено;
		МодульОбновлениеКонфигурации = ОбщегоНазначения.ОбщийМодуль("ОбновлениеКонфигурации");
		МодульОбновлениеКонфигурации.ПроверитьСтатусОбновления(РезультатОбновления, КаталогСкрипта, ИнформацияПоИсправлениям);
		ОбработатьРезультатУстановкиИсправлений(ИнформацияПоИсправлениям);
	КонецЕсли;
	
	Если ПустаяСтрока(КаталогСкрипта) Тогда 
		Элементы.ИнформацияДляТехническойПоддержки.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьРезультатУстановкиИсправлений(ИнформацияПоИсправлениям)
	
	Если ТипЗнч(ИнформацияПоИсправлениям) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ВсегоПатчей = ИнформацияПоИсправлениям.ВсегоПатчей;
	Если ВсегоПатчей = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.ГруппаУстановленныеИсправления.Видимость = Истина;
	Исправления.ЗагрузитьЗначения(ИнформацияПоИсправлениям.Установленные);
	
	Если ИнформацияПоИсправлениям.НеУстановлено > 0 Тогда
		УспешноУстановлено = ВсегоПатчей - ИнформацияПоИсправлениям.НеУстановлено;
		Ссылка = Новый ФорматированнаяСтрока(НСтр("ru = 'Не удалось установить исправления'"),,,, "НеудачнаяУстановка");
		НадписьИсправления = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '(%1 из %2)'"), УспешноУстановлено, ВсегоПатчей);
		НадписьИсправления = Новый ФорматированнаяСтрока(Ссылка, " ", НадписьИсправления);
		Элементы.ГруппаУстановленныеИсправления.ТекущаяСтраница = Элементы.ГруппаОшибкаУстановкиИсправлений;
		Элементы.ИнформацияОшибкаИсправлений.Заголовок = НадписьИсправления;
	Иначе
		Ссылка = Новый ФорматированнаяСтрока(НСтр("ru = 'Исправления (патчи)'"),,,, "УстановленныеИсправления");
		НадписьИсправления = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'успешно установлены (%1)'"), ВсегоПатчей);
		НадписьИсправления = Новый ФорматированнаяСтрока(Ссылка, " ", НадписьИсправления);
		Элементы.ИнформацияИсправленияУстановлены.Заголовок = НадписьИсправления;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьРезультатОбновленияНаКлиенте()
	
	Если РезультатОбновления <> Неопределено
		И ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		
		МодульОбновлениеКонфигурацииКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбновлениеКонфигурацииКлиент");
		МодульОбновлениеКонфигурацииКлиент.ОбработатьРезультатОбновления(РезультатОбновления, КаталогСкрипта);
		Если РезультатОбновления = Ложь Тогда
			Элементы.ГруппаРезультатыОбновления.ТекущаяСтраница = Элементы.ГруппаОшибкаОбновления;
			// Если обновление конфигурации не выполнилось, то отложенные обработчики так же не выполняются.
			Элементы.СтатусОбновления.Видимость = Ложь;
			Элементы.ПодсказкаГдеНайтиЭтуФорму.Видимость = Ложь;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьУстановленныеИсправления()
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеКонфигурации") Тогда
		МодульОбновлениеКонфигурацииКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбновлениеКонфигурацииКлиент");
		МодульОбновлениеКонфигурацииКлиент.ПоказатьУстановленныеИсправления(Исправления);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьКоличествоПотоковОбновленияИнформационнойБазы()
	
	Если ПравоДоступа("Чтение", Метаданные.Константы.КоличествоПотоковОбновленияИнформационнойБазы) Тогда
		КоличествоПотоковОбновленияИнформационнойБазы =
			ОбновлениеИнформационнойБазыСлужебный.КоличествоПотоковОбновленияИнформационнойБазы();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьДоступностьКоличестваПотоковОбновленияИнформационнойБазы(Форма)
	
	Доступно = (Форма.ПриоритетОбновления = "ОбработкаДанных");
	Форма.Элементы.КоличествоПотоковОбновленияИнформационнойБазы.Доступность = Доступно;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьВидимостьКоличестваПотоковОбновленияИнформационнойБазы()
	
	РазрешеноМногопоточноеОбновление = ОбновлениеИнформационнойБазыСлужебный.РазрешеноМногопоточноеОбновление();
	Элементы.КоличествоПотоковОбновленияИнформационнойБазы.Видимость = РазрешеноМногопоточноеОбновление;
	
	Если РазрешеноМногопоточноеОбновление Тогда
		Элементы.ПриоритетОбновления.ОтображениеПодсказки = ОтображениеПодсказки.Нет;
	Иначе
		Элементы.ПриоритетОбновления.ОтображениеПодсказки = ОтображениеПодсказки.Кнопка;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
