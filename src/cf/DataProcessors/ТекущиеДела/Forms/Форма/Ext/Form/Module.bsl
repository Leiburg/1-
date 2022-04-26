﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаСервере
Перем ВыводимыеДелаИРазделы;
&НаКлиенте
Перем ВыводитьОповещения;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ДлительнаяОперация = СформироватьСписокТекущихДелВФоне();
	ЗагрузитьНастройкиАвтообновления();
	
	Элементы.ФормаНастроить.Доступность = Ложь;
	Элементы.ФормаОбновить.Доступность  = (ДлительнаяОперация = Неопределено);
	Элементы.ФормаНастроить.Видимость   = ПравоДоступа("СохранениеДанныхПользователя", Метаданные);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВыводитьОповещения = Истина;
	Если ДлительнаяОперация <> Неопределено Тогда
		ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
		ПараметрыОжидания.Интервал = 2; // Быстрее стандартного интервала, т.к. выводится на начальной странице.
		ОповещениеОЗавершении = Новый ОписаниеОповещения("СформироватьСписокТекущихДелВФонеЗавершение", ЭтотОбъект);
		ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ТекущиеДела_ВключеноАвтообновление" Тогда
		ЗагрузитьНастройкиАвтообновления();
		ПериодОбновления = НастройкиАвтообновления.ПериодАвтообновления * 60;
		ПодключитьОбработчикОжидания("ОбновитьТекущиеДелаАвтоматически", ПериодОбновления);
	ИначеЕсли ИмяСобытия = "ТекущиеДела_ВыключеноАвтообновление" Тогда
		ОтключитьОбработчикОжидания("ОбновитьТекущиеДелаАвтоматически");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	ОтключитьОбработчикОжидания("ОбновитьТекущиеДелаАвтоматически");
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

// Параметры:
//  Элемент - ПолеФормы
//
&НаКлиенте
Процедура Подключаемый_ОбработатьНажатиеНаГиперссылку(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ОбработатьНажатиеНаГиперссылкуЗавершение", ЭтотОбъект);
	
	ПараметрыОтбора = Новый Структура();
	ПараметрыОтбора.Вставить("Идентификатор", Элемент.Имя);
	ПараметрыДела = ПараметрыДел.НайтиСтроки(ПараметрыОтбора)[0];
	
	ОткрытьФорму(ПараметрыДела.Форма, ПараметрыДела.ПараметрыФормы, ЭтотОбъект,,,, ОповещениеОЗакрытии);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбработкаНажатияНавигационнойСсылки(Элемент, Ссылка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ОбработатьНажатиеНаГиперссылкуЗавершение", ЭтотОбъект);
	
	ПараметрыОтбора = Новый Структура();
	ПараметрыОтбора.Вставить("Идентификатор", Ссылка);
	ПараметрыДела = ПараметрыДел.НайтиСтроки(ПараметрыОтбора)[0];
	
	ОткрытьФорму(ПараметрыДела.Форма, ПараметрыДела.ПараметрыФормы ,,,,, ОповещениеОЗакрытии);
	
КонецПроцедуры

// Параметры:
//  Элемент - ПолеФормы
//
&НаКлиенте
Процедура Подключаемый_ОбработатьНажатиеНаКартинку(Элемент)
	ПереключитьКартинку(Элемент.Имя);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Настроить(Команда)
	
	ОбработчикРезультата = Новый ОписаниеОповещения("ПрименитьНастройкиПанелиДел", ЭтотОбъект);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ТекущиеДела", ТекущиеДелаВХранилище);
	ОткрытьФорму("Обработка.ТекущиеДела.Форма.НастройкаТекущихДел", ПараметрыФормы,,,,,ОбработчикРезультата);
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	ЗапуститьОбновлениеСпискаТекущихДел();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции формирования списка дел пользователя.

&НаКлиенте
Процедура ОбновитьТекущиеДелаАвтоматически()
	ЗапуститьОбновлениеСпискаТекущихДел(Истина);
КонецПроцедуры

&НаСервере
Процедура СформироватьСписокТекущихДел(ТекущиеДела)
	
	ЭтоМобильныйКлиент = ОбщегоНазначения.ЭтоМобильныйКлиент();
	ПараметрыДел.Очистить();
	РазделыСВажнымиДелами = Новый Структура;
	СохраненныеНастройкиОтображения = ТекущиеДелаСлужебный.СохраненныеНастройкиОтображения();
	Если СохраненныеНастройкиОтображения = Неопределено Тогда
		ЗаданнаяВидимостьРазделов = Новый Соответствие;
		ЗаданнаяВидимостьДел      = Новый Соответствие;
	Иначе
		СохраненныеНастройкиОтображения.Свойство("ВидимостьРазделов", ЗаданнаяВидимостьРазделов);
		СохраненныеНастройкиОтображения.Свойство("ВидимостьДел", ЗаданнаяВидимостьДел);
	КонецЕсли;
	
	СвернутыеРазделы = СвернутыеРазделы();
	
	ТекущиеДела.Сортировать("ЭтоРаздел Убыв, ПредставлениеРаздела Возр, Важное Убыв");
	
	ПоместитьВоВременноеХранилище(ТекущиеДела, ТекущиеДелаВХранилище);
	
	// Если пользователь не настраивал положение разделов в списке дел, то
	// они сортируются согласно порядку, определенному в процедуре ПриОпределенииПорядкаРазделовКомандногоИнтерфейса.
	Если СохраненныеНастройкиОтображения = Неопределено Тогда
		ТекущиеДелаСлужебный.УстановитьНачальныйПорядокРазделов(ТекущиеДела);
	КонецЕсли;
	
	ТекущаяГруппа = "";
	ТекущаяОбщаяГруппа = "";
	Для Каждого Дело Из ТекущиеДела Цикл
		
		Если Дело.ЭтоРаздел Тогда
			
			// Создание общей группы раздела.
			ИмяОбщейГруппы = "ОбщаяГруппа" + Дело.ИдентификаторВладельца;
			Если ТекущаяОбщаяГруппа <> ИмяОбщейГруппы Тогда
				
				РазделСвернут = СвернутыеРазделы[Дело.ИдентификаторВладельца];
				Если РазделСвернут = Неопределено Тогда
					Если СохраненныеНастройкиОтображения = Неопределено
						И ТекущаяОбщаяГруппа <> "" Тогда
						// Первая группа не сворачивается.
						СвернутыеРазделы.Вставить(Дело.ИдентификаторВладельца, Истина);
						РазделСвернут = Истина;
					Иначе
						СвернутыеРазделы.Вставить(Дело.ИдентификаторВладельца, Ложь);
					КонецЕсли;
					
				КонецЕсли;
				
				ВключенаВидимостьРаздела = ЗаданнаяВидимостьРазделов[Дело.ИдентификаторВладельца];
				Если ВключенаВидимостьРаздела = Неопределено Тогда
					ВключенаВидимостьРаздела = Истина;
				КонецЕсли;
				
				// Создание общей группы, содержащей все элементы для отображения раздела и включенных в него дел.
				ОбщаяГруппа = Группа(ИмяОбщейГруппы,, "ОбщаяГруппа");
				ОбщаяГруппа.Видимость = Ложь;
				// Создание группы заголовка раздела.
				ИмяГруппыЗаголовка = "ЗаголовокРаздела" + Дело.ИдентификаторВладельца;
				ГруппаЗаголовка    = Группа(ИмяГруппыЗаголовка, ОбщаяГруппа, "ЗаголовокРаздела");
				// Создание заголовка раздела.
				СоздатьЗаголовок(Дело, ГруппаЗаголовка, РазделСвернут);
				
				ТекущаяОбщаяГруппа = ИмяОбщейГруппы;
			КонецЕсли;
			
			// Создание группы дел.
			ИмяГруппы = "Группа" + Дело.ИдентификаторВладельца;
			Если ТекущаяГруппа <> ИмяГруппы Тогда
				ТекущаяГруппа = ИмяГруппы;
				Группа        = Группа(ИмяГруппы, ОбщаяГруппа);
				Если ЭтоМобильныйКлиент Тогда
					ВариантОтображения = ОтображениеОбычнойГруппы.Нет;
				Иначе
					ВариантОтображения = ОтображениеОбычнойГруппы.СильноеВыделение;
				КонецЕсли;
				Группа.Отображение = ВариантОтображения;
				
				Если РазделСвернут = Истина Тогда
					Группа.Видимость = Ложь;
				КонецЕсли;
			КонецЕсли;
			
			ВключенаВидимостьДела = ЗаданнаяВидимостьДел[Дело.Идентификатор];
			Если ВключенаВидимостьДела = Неопределено Тогда
				ВключенаВидимостьДела = Истина;
			КонецЕсли;
			
			Если ВключенаВидимостьРаздела И ВключенаВидимостьДела И Дело.ЕстьДела Тогда
				ВыводимыеДелаИРазделы.Вставить(ИмяГруппыЗаголовка);
				ОбщаяГруппа.Видимость = Истина;
			КонецЕсли;
			
			СоздатьДело(Дело, Группа, ВключенаВидимостьДела);
			
			// Включение индикатора наличия важных дел.
			Если Дело.ЕстьДела
				И Дело.Важное
				И ВключенаВидимостьДела Тогда
				
				РазделыСВажнымиДелами.Вставить(Дело.ИдентификаторВладельца, СвернутыеРазделы[Дело.ИдентификаторВладельца]);
			КонецЕсли;
			
		Иначе
			СоздатьДочернееДело(Дело);
		КонецЕсли;
		
		ЗаполнитьПараметрыДела(Дело);
		
	КонецЦикла;
	
	ДобавитьДелаСОповещением(СохраненныеНастройкиОтображения, ТекущиеДела);
	
	СохранитьСвернутыеРазделы(СвернутыеРазделы);
	
КонецПроцедуры

&НаСервере
Процедура УпорядочитьСписокТекущихДел()
	
	СохраненныеНастройкиОтображения = ТекущиеДелаСлужебный.СохраненныеНастройкиОтображения();
	Если СохраненныеНастройкиОтображения = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СохраненноеДеревоДел = СохраненныеНастройкиОтображения.ДеревоДел;
	ЭтоПервыйРаздел = Истина;
	Для Каждого СтрокаРаздел Из СохраненноеДеревоДел.Строки Цикл
		Если Не ЭтоПервыйРаздел Тогда
			ПереместитьРаздел(СтрокаРаздел);
		КонецЕсли;
		ЭтоПервыйРаздел = Ложь;
		ЭтоПервоеДело   = Истина;
		Для Каждого СтрокаДело Из СтрокаРаздел.Строки Цикл
			Если Не ЭтоПервоеДело Тогда
				ПереместитьДело(СтрокаДело);
			КонецЕсли;
			ЭтоПервоеДело = Ложь;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Фоновое обновление

&НаСервере
Функция СформироватьСписокТекущихДелВФоне()
	
	Если МонопольныйРежим() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ДлительнаяОперация <> Неопределено Тогда
		ДлительныеОперации.ОтменитьВыполнениеЗадания(ДлительнаяОперация.ИдентификаторЗадания);
	КонецЕсли;
	
	Если ТекущиеДелаВХранилище = "" Тогда
		ТекущиеДелаВХранилище = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
	КонецЕсли;
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.ОжидатьЗавершение = 0; // запускать сразу
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Обновление списка текущих дел'");
	ПараметрыВыполнения.АдресРезультата = ТекущиеДелаВХранилище;
	ПараметрыВыполнения.ЗапуститьВФоне = Истина; // Всегда в фоне (очередь заданий в файловом варианте).
	
	Результат = ДлительныеОперации.ВыполнитьВФоне("ТекущиеДелаСлужебный.СформироватьСписокТекущихДелПользователя",
		Новый Структура, ПараметрыВыполнения);
		
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ЗагрузитьТекущиеДела(АдресТекущихДел)
	
	ТекущиеДела = ПолучитьИзВременногоХранилища(АдресТекущихДел); // см. ТекущиеДелаСервер.ТекущиеДела
	ВыводимыеДелаИРазделы = Новый Структура;
	Если ТолькоОбновлениеДел Тогда
		ЗаполнитьСвернутыеГруппы();
		
		РазделыДляУдаления = Новый Массив;
		Для Каждого Элемент Из Элементы.СтраницаДела.ПодчиненныеЭлементы Цикл
			РазделыДляУдаления.Добавить(Элемент);
		КонецЦикла;
		
		Для Каждого УдаляемыйЭлемент Из РазделыДляУдаления Цикл
			Элементы.Удалить(УдаляемыйЭлемент);
		КонецЦикла;
		РазделыДляУдаления = Неопределено;
		
		СформироватьСписокТекущихДел(ТекущиеДела);
	Иначе
		ТолькоОбновлениеДел = Истина;
		СформироватьСписокТекущихДел(ТекущиеДела);
	КонецЕсли;
	
	// Если есть свернутые разделы с важными делами - они выделяются.
	УстановитьКартинкуРазделовСВажнымиДелами();
	
	Если ВыводимыеДелаИРазделы.Количество() = 0 Тогда
		Элементы.СтраницаТекущихДелНет.Видимость = Истина;
	Иначе
		Элементы.СтраницаТекущихДелНет.Видимость = Ложь;
		// Если выводятся дела только из одного раздела - скрываем его заголовок.
		Если ВыводимыеДелаИРазделы.Количество() = 1 Тогда
			ОтображатьРаздел = Ложь;
		Иначе
			ОтображатьРаздел = Истина;
		КонецЕсли;
		Для Каждого ЭлементЗаголовокРаздела Из ВыводимыеДелаИРазделы Цикл
			ЗаголовокРаздела = ЭлементЗаголовокРаздела.Ключ;
			Элементы[ЗаголовокРаздела].Видимость = ОтображатьРаздел;
			
			Если Не ОтображатьРаздел Тогда
				ИмяГруппыДел = СтрЗаменить(ЗаголовокРаздела, "ЗаголовокРаздела", "Группа");
				Элементы[ИмяГруппыДел].Видимость = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	УпорядочитьСписокТекущихДел();
	
КонецПроцедуры

&НаКлиенте
Процедура СформироватьСписокТекущихДелВФонеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ДлительнаяОперация = Неопределено;
	
	Элементы.СтраницаДела.Видимость    = Истина;
	Элементы.СтраницаДлительнаяОперация.Видимость = Ложь;
	Элементы.СтраницаОшибка.Видимость  = Ложь;
	Элементы.ФормаОбновить.Доступность = Истина;

	Если Результат = Неопределено Тогда
		Элементы.ФормаНастроить.Доступность = ТолькоОбновлениеДел;
		Возврат;
	ИначеЕсли Результат.Статус = "Ошибка" Тогда
		Элементы.ФормаНастроить.Доступность = ТолькоОбновлениеДел;
		Элементы.СтраницаДела.Видимость     = Ложь;
		Элементы.СтраницаОшибка.Видимость   = Истина;
		ТекстОшибки = Результат.ПодробноеПредставлениеОшибки;
		Возврат;
	ИначеЕсли Результат.Статус = "Выполнено" Тогда
		ЗагрузитьТекущиеДела(Результат.АдресРезультата);
		Если ВыводитьОповещения Тогда
			Картинка = БиблиотекаКартинок.Информация32;
			Для Каждого ДелоСОповещением Из ДелаСОповещением Цикл
				ОбработкаОповещения = Новый ОписаниеОповещения("ПереходКВажномуДелуИзЦентраОповещений", ЭтотОбъект, 
					ДелоСОповещением.Идентификатор);
				ПоказатьОповещениеПользователя(НСтр("ru = 'Текущие дела'"),
					ОбработкаОповещения, ДелоСОповещением.Описание, Картинка, СтатусОповещенияПользователя.Важное,
					ДелоСОповещением.Идентификатор);
			КонецЦикла;
		КонецЕсли;
		ВыводитьОповещения = Истина;
		Элементы.ФормаНастроить.Доступность = Истина;
		Если НастройкиАвтообновления.Свойство("АвтообновлениеВключено")
			И НастройкиАвтообновления.АвтообновлениеВключено Тогда
			ПериодОбновления = НастройкиАвтообновления.ПериодАвтообновления * 60;
			ПодключитьОбработчикОжидания("ОбновитьТекущиеДелаАвтоматически", ПериодОбновления);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции.

&НаКлиенте
Процедура ПереходКВажномуДелуИзЦентраОповещений(Идентификатор) Экспорт
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ОбработатьНажатиеНаГиперссылкуЗавершение", ЭтотОбъект);
	
	ПараметрыОтбора = Новый Структура();
	ПараметрыОтбора.Вставить("Идентификатор", Идентификатор);
	ПараметрыДела = ПараметрыДел.НайтиСтроки(ПараметрыОтбора)[0];
	
	ОткрытьФорму(ПараметрыДела.Форма, ПараметрыДела.ПараметрыФормы,,,,, ОповещениеОЗакрытии);
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьОбновлениеСпискаТекущихДел(АвтоматическоеОбновление = Ложь, ОбновитьНезаметно = Ложь)
	
	// Если обновление инициировано вручную - обработчик автоматического обновления дел отключается.
	// Он будет подключен заново после завершения "ручного" обновления.
	Если Не АвтоматическоеОбновление Тогда
		ОтключитьОбработчикОжидания("ОбновитьТекущиеДелаАвтоматически");
	КонецЕсли;
	
	ДлительнаяОперация = СформироватьСписокТекущихДелВФоне();
	Если ДлительнаяОперация = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Не ОбновитьНезаметно Тогда
		Элементы.СтраницаДела.Видимость = Ложь;
		Элементы.СтраницаДлительнаяОперация.Видимость = Истина;
		Элементы.СтраницаОшибка.Видимость   = Ложь;
		Элементы.ФормаНастроить.Доступность = Ложь;
		Элементы.ФормаОбновить.Доступность  = Ложь;
		Элементы.СтраницаТекущихДелНет.Видимость = Ложь;
	КонецЕсли;
	
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	ПараметрыОжидания.Интервал = 2; // Быстрее стандартного интервала, т.к. выводится на начальной странице.
	ОповещениеОЗавершении = Новый ОписаниеОповещения("СформироватьСписокТекущихДелВФонеЗавершение", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция Группа(ИмяГруппы, Родитель = Неопределено, ТипГруппы = "")
	
	Если Родитель = Неопределено Тогда
		Родитель = Элементы.СтраницаДела;
	КонецЕсли;
	
	Группа = Элементы.Добавить(ИмяГруппы, Тип("ГруппаФормы"), Родитель);
	Группа.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	Группа.Отображение = ОтображениеОбычнойГруппы.Нет;
	
	Если ТипГруппы = "ЗаголовокРаздела" Тогда
		Группа.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	Иначе
		Группа.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная;
	КонецЕсли;
	
	Группа.ОтображатьЗаголовок = Ложь;
	
	Возврат Группа;
	
КонецФункции

&НаСервере
Процедура СоздатьДело(Дело, Группа, ВключенаВидимостьДела)
	
	ЗаголовокДела = Дело.Представление + ?(Дело.Количество <> 0," (" + Дело.Количество + ")", "");
	
	Элемент = Элементы.Добавить(Дело.Идентификатор, Тип("ДекорацияФормы"), Группа); // РасширениеПоляФормыДляПоляНадписи
	Элемент.Вид = ВидДекорацииФормы.Надпись;
	Элемент.ГоризонтальноеПоложение = ГоризонтальноеПоложениеЭлемента.Лево;
	Элемент.Заголовок = ЗаголовокДела;
	Элемент.Видимость = (ВключенаВидимостьДела И Дело.ЕстьДела);
	Элемент.АвтоМаксимальнаяШирина = Ложь;
	Элемент.Гиперссылка = ЗначениеЗаполнено(Дело.Форма);
	Элемент.УстановитьДействие("Нажатие", "Подключаемый_ОбработатьНажатиеНаГиперссылку");
	
	Если Дело.Важное Тогда
		Элемент.ЦветТекста = ЦветаСтиля.ПросроченныеДанныеЦвет;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Дело.Подсказка) Тогда
		Подсказка                    = Новый ФорматированнаяСтрока(Дело.Подсказка);
		Элемент.Подсказка            = Подсказка;
		Элемент.ОтображениеПодсказки = ОтображениеПодсказки.Кнопка;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СоздатьЗаголовок(Дело, Группа, РазделСвернут)
	
	// Создание картинки сворачивания/разворачивания раздела.
	Элемент = Элементы.Добавить("Картинка" + Дело.ИдентификаторВладельца, Тип("ДекорацияФормы"), Группа); // РасширениеПоляФормыДляПоляНадписи
	Элемент.Вид = ВидДекорацииФормы.Картинка;
	Элемент.Гиперссылка = Истина;
	
	Если РазделСвернут = Истина Тогда
		Если Дело.ЕстьДела И Дело.Важное Тогда
			Элемент.Картинка = БиблиотекаКартинок.СтрелкаВправоКрасная;
		Иначе
			Элемент.Картинка = БиблиотекаКартинок.СтрелкаВправо;
		КонецЕсли;
	Иначе
		Элемент.Картинка = БиблиотекаКартинок.СтрелкаВниз;
	КонецЕсли;
	
	Элемент.РазмерКартинки = РазмерКартинки.АвтоРазмер;
	Элемент.Ширина      = 2;
	Элемент.Высота      = 1;
	Элемент.УстановитьДействие("Нажатие", "Подключаемый_ОбработатьНажатиеНаКартинку");
	Элемент.Подсказка = НСтр("ru = 'Развернуть/свернуть раздел'");
	
	// Создание заголовка раздела.
	Элемент = Элементы.Добавить("Заголовок" + Дело.ИдентификаторВладельца, Тип("ДекорацияФормы"), Группа);
	Элемент.Вид = ВидДекорацииФормы.Надпись;
	Элемент.ГоризонтальноеПоложение = ГоризонтальноеПоложениеЭлемента.Лево;
	Элемент.Заголовок  = Дело.ПредставлениеРаздела;
	Элемент.Шрифт = ШрифтыСтиля.ТекущиеДелаЗаголовокРазделаШрифт;
	
КонецПроцедуры

&НаСервере
Процедура СоздатьДочернееДело(Дело)
	
	Если Не Дело.ЕстьДела Тогда
		Возврат;
	КонецЕсли;
	
	ЭлементДелоВладелец = Элементы.Найти(Дело.ИдентификаторВладельца);
	Если ЭлементДелоВладелец = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ЭлементДелоВладелец.ОтображениеПодсказки           = ОтображениеПодсказки.ОтображатьСнизу;
	ЭлементДелоВладелец.РасширеннаяПодсказка.Шрифт     = ШрифтыСтиля.ТекущиеДелаЗаголовокДочернегоДела;
	ЭлементДелоВладелец.РасширеннаяПодсказка.РастягиватьПоГоризонтали = Истина;
	
	ЗаголовокПодчиненногоДела = ЗаголовокПодчиненногоДела(ЭлементДелоВладелец.РасширеннаяПодсказка.Заголовок, Дело);
	
	ЭлементДелоВладелец.РасширеннаяПодсказка.Заголовок = ЗаголовокПодчиненногоДела;
	ЭлементДелоВладелец.РасширеннаяПодсказка.УстановитьДействие("ОбработкаНавигационнойСсылки", "Подключаемый_ОбработкаНажатияНавигационнойСсылки");
	ЭлементДелоВладелец.РасширеннаяПодсказка.АвтоМаксимальнаяШирина = Ложь;
	
	// Включение индикатора наличия важных дел.
	Если Дело.ЕстьДела
		И Дело.Важное
		И ЭлементДелоВладелец.Видимость Тогда
		
		ИдентификаторРаздела = СтрЗаменить(ЭлементДелоВладелец.Родитель.Имя, "Группа", "");
		РазделыСВажнымиДелами.Вставить(ИдентификаторРаздела, Не ЭлементДелоВладелец.Родитель.Видимость);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗаголовокПодчиненногоДела(ТекущийЗаголовок, Дело)
	
	ТекущийЗаголовокПустой = Не ЗначениеЗаполнено(ТекущийЗаголовок);
	ЗаголовокДела = Дело.Представление + ?(Дело.Количество <> 0," (" + Дело.Количество + ")", "");
	СтрокаЗаголовкаДела    = ЗаголовокДела;
	Если Дело.Важное Тогда
		ЦветДела        = ЦветаСтиля.ПросроченныеДанныеЦвет;
	Иначе
		ЦветДела        = ЦветаСтиля.ЗаголовокДелаЦвет;
	КонецЕсли;
	
	ФорматированнаяСтрокаПеренос = Новый ФорматированнаяСтрока(Символы.ПС);
	ФорматированнаяСтрокаОтступ  = Новый ФорматированнаяСтрока(Символы.НПП+Символы.НПП+Символы.НПП);
	
	Если Дело.Важное Тогда
		Если ЗначениеЗаполнено(Дело.Форма) Тогда
			ФорматированнаяСтрокаЗаголовкаДела = Новый ФорматированнаяСтрока(
			                                           СтрокаЗаголовкаДела,,
			                                           ЦветДела,,
			                                           Дело.Идентификатор);
		Иначе
			ФорматированнаяСтрокаЗаголовкаДела = Новый ФорматированнаяСтрока(
			                                           СтрокаЗаголовкаДела,,
			                                           ЦветДела);
		КонецЕсли;
	Иначе
		Если ЗначениеЗаполнено(Дело.Форма) Тогда
			ФорматированнаяСтрокаЗаголовкаДела = Новый ФорматированнаяСтрока(
			                                           СтрокаЗаголовкаДела,,,,
			                                           Дело.Идентификатор);
		Иначе
			ФорматированнаяСтрокаЗаголовкаДела = Новый ФорматированнаяСтрока(СтрокаЗаголовкаДела,,ЦветДела);
		КонецЕсли;
	КонецЕсли;
	
	Если ТекущийЗаголовокПустой Тогда
		Возврат Новый ФорматированнаяСтрока(ФорматированнаяСтрокаОтступ, ФорматированнаяСтрокаЗаголовкаДела);
	Иначе
		Возврат Новый ФорматированнаяСтрока(ТекущийЗаголовок, ФорматированнаяСтрокаПеренос, ФорматированнаяСтрокаОтступ, ФорматированнаяСтрокаЗаголовкаДела);
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьПараметрыДела(Дело)
	
	ЗаполнитьЗначенияСвойств(ПараметрыДел.Добавить(), Дело);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьНастройкиАвтообновления()
	
	НастройкиАвтообновления = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ТекущиеДела", "НастройкиАвтообновления");
	
	Если НастройкиАвтообновления = Неопределено Тогда
		НастройкиАвтообновления = Новый Структура;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПрименитьНастройкиПанелиДел(ПрименитьНастройки, ДополнительныеПараметры) Экспорт
	Если ПрименитьНастройки = Истина Тогда
		ВыводитьОповещения = Ложь;
		ЗапуститьОбновлениеСпискаТекущихДел();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПереместитьРаздел(СтрокаРаздел)
	
	ИмяЭлемента = "ОбщаяГруппа" + СтрокаРаздел.Идентификатор;
	ПеремещаемыйЭлемент = Элементы.Найти(ИмяЭлемента);
	Если ПеремещаемыйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Элементы.Переместить(ПеремещаемыйЭлемент, ПеремещаемыйЭлемент.Родитель);
	
КонецПроцедуры

&НаСервере
Процедура ПереместитьДело(СтрокаДело)
	
	ПеремещаемыйЭлемент = Элементы.Найти(СтрокаДело.Идентификатор);
	Если ПеремещаемыйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Элементы.Переместить(ПеремещаемыйЭлемент, ПеремещаемыйЭлемент.Родитель);
	
КонецПроцедуры

&НаСервере
Процедура СохранитьСвернутыеРазделы(СвернутыеРазделы)
	
	НастройкиОтображения = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ТекущиеДела", "НастройкиОтображения");
	
	Если ТипЗнч(НастройкиОтображения) <> Тип("Структура") Тогда
		НастройкиОтображения = Новый Структура;
	КонецЕсли;
	
	НастройкиОтображения.Вставить("СвернутыеРазделы", СвернутыеРазделы);
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ТекущиеДела", "НастройкиОтображения", НастройкиОтображения);
	
КонецПроцедуры

&НаСервере
Функция СвернутыеРазделы()
	
	НастройкиОтображения = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ТекущиеДела", "НастройкиОтображения");
	Если НастройкиОтображения <> Неопределено И НастройкиОтображения.Свойство("СвернутыеРазделы") Тогда
		СвернутыеРазделы = НастройкиОтображения.СвернутыеРазделы;
	Иначе
		СвернутыеРазделы = Новый Соответствие;
	КонецЕсли;
	
	Возврат СвернутыеРазделы;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьСвернутыеГруппы()
	
	НастройкиОтображения = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ТекущиеДела", "НастройкиОтображения");
	Если НастройкиОтображения = Неопределено Или Не НастройкиОтображения.Свойство("СвернутыеРазделы") Тогда
		Возврат;
	КонецЕсли;
	
	КартинкаСтрелкаВправо = БиблиотекаКартинок.СтрелкаВправо;
	КартинкаСтрелкаВправоКрасная = БиблиотекаКартинок.СтрелкаВправоКрасная;
	СвернутыеРазделы = Новый Соответствие;
	Для Каждого СтрокаСоответствия Из НастройкиОтображения.СвернутыеРазделы Цикл
		
		ЭлементФормы = Элементы.Найти("Картинка" + СтрокаСоответствия.Ключ);
		Если ЭлементФормы = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Если ЭлементФормы.Картинка = КартинкаСтрелкаВправо
			Или ЭлементФормы.Картинка = КартинкаСтрелкаВправоКрасная Тогда
			СвернутыеРазделы.Вставить(СтрокаСоответствия.Ключ, Истина);
		Иначе
			СвернутыеРазделы.Вставить(СтрокаСоответствия.Ключ, Ложь);
		КонецЕсли;
		
	КонецЦикла;
	
	Если СвернутыеРазделы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	СохранитьСвернутыеРазделы(СвернутыеРазделы);
	
КонецПроцедуры

&НаСервере
Процедура ПереключитьКартинку(ИмяЭлемента)
	
	ИмяГруппыРаздела = СтрЗаменить(ИмяЭлемента, "Картинка", "");
	Элемент = Элементы[ИмяЭлемента];
	
	Свернут = Ложь;
	Если Элемент.Картинка = БиблиотекаКартинок.СтрелкаВниз Тогда
		Если РазделыСВажнымиДелами.Свойство(ИмяГруппыРаздела) Тогда
			Элемент.Картинка = БиблиотекаКартинок.СтрелкаВправоКрасная;
		Иначе
			Элемент.Картинка = БиблиотекаКартинок.СтрелкаВправо;
		КонецЕсли;
		Элементы["Группа" + ИмяГруппыРаздела].Видимость = Ложь;
		Свернут = Истина;
	Иначе
		Элемент.Картинка = БиблиотекаКартинок.СтрелкаВниз;
		Элементы["Группа" + ИмяГруппыРаздела].Видимость = Истина;
	КонецЕсли;
	
	СвернутыеРазделы = СвернутыеРазделы();
	СвернутыеРазделы.Вставить(ИмяГруппыРаздела, Свернут);
	
	СохранитьСвернутыеРазделы(СвернутыеРазделы);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьКартинкуРазделовСВажнымиДелами()
	
	Картинка = БиблиотекаКартинок.СтрелкаВправоКрасная;
	Для Каждого РазделСВажнымиДелами Из РазделыСВажнымиДелами Цикл
		Если РазделСВажнымиДелами.Значение <> Истина Тогда
			Продолжить; // Раздел не свернут
		КонецЕсли;
		ИмяКартинки = "Картинка" + РазделСВажнымиДелами.Ключ;
		ЭлементКартинка = Элементы[ИмяКартинки];
		ЭлементКартинка.Картинка = Картинка;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьНажатиеНаГиперссылкуЗавершение(Результат, ДополнительныеПараметры) Экспорт
	ВыводитьОповещения = Ложь;
	ЗапуститьОбновлениеСпискаТекущихДел(, Истина);
КонецПроцедуры

&НаСервере
Процедура ДобавитьДелаСОповещением(СохраненныеНастройкиОтображения, ТекущиеДела)
	
	ДелаСОповещением.Очистить();
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("ВыводитьВОповещениях", Истина);
	
	Если СохраненныеНастройкиОтображения <> Неопределено
		И СохраненныеНастройкиОтображения.ДеревоДел.Колонки.Найти("ВыводитьВОповещениях") <> Неопределено Тогда
		НайденныеСтроки = СохраненныеНастройкиОтображения.ДеревоДел.Строки.НайтиСтроки(ПараметрыОтбора, Истина);
		Для Каждого Строка Из НайденныеСтроки Цикл
			Дело = ТекущиеДела.Найти(Строка.Идентификатор, "Идентификатор");
			
			Если Дело = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			
			Если Дело <> Неопределено И Не Дело.ЕстьДела Тогда
				Продолжить;
			КонецЕсли;
			
			Если СохраненныеНастройкиОтображения.ВидимостьДел[Строка.Идентификатор] = Ложь Тогда
				Продолжить;
			КонецЕсли;
			
			Если Дело.Количество <> 0 Тогда
				Добавка = " (" + Дело.Количество + ")";
			Иначе
				Добавка = "";
			КонецЕсли;
			
			ДелоСОповещением = ДелаСОповещением.Добавить();
			ДелоСОповещением.Идентификатор = Строка.Идентификатор;
			ДелоСОповещением.Описание = Строка.Представление + Добавка;
		КонецЦикла;
	КонецЕсли;
	
	НайденныеСтроки = ТекущиеДела.НайтиСтроки(ПараметрыОтбора);
	Для Каждого Строка Из НайденныеСтроки Цикл
		Если СохраненныеНастройкиОтображения <> Неопределено
			И СохраненныеНастройкиОтображения.ВидимостьДел[Строка.Идентификатор] <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не Строка.ЕстьДела Тогда
			Продолжить;
		КонецЕсли;
		
		Если Строка.Количество <> 0 Тогда
			Добавка = " (" + Строка.Количество + ")";
		Иначе
			Добавка = "";
		КонецЕсли;
		
		ДелоСОповещением = ДелаСОповещением.Добавить();
		ДелоСОповещением.Идентификатор = Строка.Идентификатор;
		ДелоСОповещением.Описание = Строка.Представление + Добавка;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
