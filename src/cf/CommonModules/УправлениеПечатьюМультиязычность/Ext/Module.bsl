﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	Обработчик = Обработчики.Добавить();
	Обработчик.НачальноеЗаполнение = Истина;
	Обработчик.Версия = "3.1.4.67";
	Обработчик.Процедура = "Справочники.ЯзыкиПечатныхФорм.ЗаполнитьПоставляемыеЯзыки";
	Обработчик.РежимВыполнения = "Оперативно";
	
КонецПроцедуры

Функция ДоступныеЯзыки(СРегиональнымиНастройками = Ложь) Экспорт
	
	Возврат Справочники.ЯзыкиПечатныхФорм.ДоступныеЯзыки(СРегиональнымиНастройками);
	
КонецФункции

Функция ДополнительныеЯзыкиПечатныхФорм() Экспорт
	
	Возврат Справочники.ЯзыкиПечатныхФорм.ДополнительныеЯзыкиПечатныхФорм();
	
КонецФункции

Функция ЭтоДополнительныйЯзыкПечатныхФорм(КодЯзыка) Экспорт
	
	Возврат Справочники.ЯзыкиПечатныхФорм.ЭтоДополнительныйЯзыкПечатныхФорм(КодЯзыка);
	
КонецФункции

Функция ПредставлениеЯзыка(КодЯзыка) Экспорт
	
	Возврат МультиязычностьСервер.ПредставлениеЯзыка(КодЯзыка);
	
КонецФункции

Функция ЯзыкиМакета(ПутьКМакету) Экспорт
	
	ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Макет ""%1"" не существует. Операция прервана.'"), ПутьКМакету);
	ЧастиПути = СтрРазделить(ПутьКМакету, ".", Истина);
	Если ЧастиПути.Количество() <> 2 И ЧастиПути.Количество() <> 3 Тогда
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	ИмяМакета = ЧастиПути[ЧастиПути.ВГраница()];
	ЧастиПути.Удалить(ЧастиПути.ВГраница());
	ИмяОбъекта = СтрСоединить(ЧастиПути, ".");
	
	ЯзыкиПечатныхФорм = ДоступныеЯзыки();
	Для Каждого КодЯзыка Из ЯзыкиПечатныхФорм Цикл
		Если СтрЗаканчиваетсяНа(ИмяМакета, "_" + КодЯзыка) Тогда
			ИмяМакета = Лев(ИмяМакета, СтрДлина(ИмяМакета) - СтрДлина(КодЯзыка) - 1);
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	ПользовательскиеМакетыПечати.ИмяМакета КАК ИмяМакета
	|ИЗ
	|	РегистрСведений.ПользовательскиеМакетыПечати КАК ПользовательскиеМакетыПечати
	|ГДЕ
	|	ПользовательскиеМакетыПечати.Объект = &Объект
	|	И ПользовательскиеМакетыПечати.ИмяМакета ПОДОБНО &ШаблонИмениМакета
	|	И ПользовательскиеМакетыПечати.Использование";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.Параметры.Вставить("Объект", ИмяОбъекта);
	Запрос.Параметры.Вставить("ШаблонИмениМакета", ИмяМакета + "_%");
	
	Выборка = Запрос.Выполнить().Выбрать();
	НайденныеЯзыки = Новый Соответствие;
	
	Пока Выборка.Следующий() Цикл
		Для Каждого КодЯзыка Из ЯзыкиПечатныхФорм Цикл
			КодЛокализации = КодЯзыка;
			Если СтрЗаканчиваетсяНа(Выборка.ИмяМакета, "_" + КодЛокализации) Тогда
				НайденныеЯзыки.Вставить(КодЛокализации, Истина);
				Продолжить;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	ИменаПоиска = Новый Соответствие;
	Для Каждого КодЯзыка Из ДополнительныеЯзыкиПечатныхФорм() Цикл
		ИменаПоиска.Вставить(КодЯзыка, ИмяМакета + "_" + КодЯзыка);
	КонецЦикла;
	
	ЭтоОбщийМакет = СтрРазделить(ИмяОбъекта, ".").Количество() = 1;
	
	КоллекцияМакетов = Метаданные.ОбщиеМакеты;
	Если Не ЭтоОбщийМакет Тогда
		ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ИмяОбъекта);
		Если ОбъектМетаданных = Неопределено Тогда
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
		КоллекцияМакетов = ОбъектМетаданных.Макеты;
	КонецЕсли;
	
	Для Каждого Элемент Из ИменаПоиска Цикл
		ИмяПоиска = Элемент.Значение;
		КодЯзыка = Элемент.Ключ;
		Если КоллекцияМакетов.Найти(ИмяПоиска) <> Неопределено Тогда
			НайденныеЯзыки.Вставить(КодЯзыка, Истина);
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого КодЯзыка Из СтандартныеПодсистемыСервер.ЯзыкиКонфигурации() Цикл
		НайденныеЯзыки.Вставить(КодЯзыка, Истина);
	КонецЦикла;
	
	Результат = Новый Массив;
	Для Каждого КодЯзыка Из ЯзыкиПечатныхФорм Цикл
		Если НайденныеЯзыки[КодЯзыка] <> Неопределено Тогда
			Результат.Добавить(КодЯзыка);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПредставлениеЯзыковМакета(ИмяОбъектаМетаданныхМакета) Экспорт
	
	ПредставленияЯзыков = Новый Массив;
	Для Каждого КодЯзыка Из ЯзыкиМакета(ИмяОбъектаМетаданныхМакета) Цикл
		Если ЭтоДополнительныйЯзыкПечатныхФорм(КодЯзыка) Тогда
			ПредставленияЯзыков.Добавить(ПредставлениеЯзыка(КодЯзыка));
		КонецЕсли;
	КонецЦикла;
	
	Возврат СтрСоединить(ПредставленияЯзыков, ", ");
	
КонецФункции

// Параметры:
//   НаборЯзыков - ТаблицаЗначений:
//    * КодЯзыка - Строка
//    * Представление - Строка
//    * Суффикс - Строка
//
Процедура ПриЗаполненииНабораЯзыков(НаборЯзыков) Экспорт
	
	ПредставленияЯзыков = Новый Соответствие;
	Для Каждого ЯзыкКонфигурации Из Метаданные.Языки Цикл
		ПредставленияЯзыков.Вставить(ЯзыкКонфигурации.КодЯзыка, ЯзыкКонфигурации.Представление());
	КонецЦикла;
	
	Для Каждого КодЯзыка Из ДоступныеЯзыки() Цикл
		НовыйЯзык = НаборЯзыков.Добавить();
		НовыйЯзык.КодЯзыка = КодЯзыка;
		ПредставлениеЯзыка = ПредставленияЯзыков[КодЯзыка];
		Если Не ЗначениеЗаполнено(ПредставлениеЯзыка) Тогда
			ПредставлениеЯзыка = ПредставлениеЯзыка(КодЯзыка);
		КонецЕсли;
		НовыйЯзык.Представление = ПредставлениеЯзыка;
	КонецЦикла;
	
КонецПроцедуры

Функция ИспользуютсяДополнительныеЯзыкиПечатныхФорм() Экспорт
	
	Возврат Справочники.ЯзыкиПечатныхФорм.ДополнительныеЯзыкиПечатныхФорм().Количество() > 0
	
КонецФункции

// Параметры:
//   Форма - ФормаКлиентскогоПриложения:
//     * Элементы - ВсеЭлементыФормы:
//       ** Язык - ГруппаФормы 
//   ТекущийЯзык - Строка
//   Отбор - Массив из Строка
//
Процедура ЗаполнитьПодменюЯзык(Форма, ТекущийЯзык = Неопределено, Знач Отбор = Неопределено) Экспорт
	
	ИспользоватьРегиональныеПредставленияЯзыков = Истина; // Для формы печати.
	Если Отбор = Неопределено Тогда
		Отбор = ДоступныеЯзыки();
		ИспользоватьРегиональныеПредставленияЯзыков = Ложь; // Для формы редактирования.
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекущийЯзык) Тогда
		ТекущийЯзык = ОбщегоНазначения.КодОсновногоЯзыка();
		Если Отбор.Найти(ТекущийЯзык) = Неопределено Тогда
			Для Каждого КодЯзыка Из Отбор Цикл
				Если СтрНачинаетсяС(КодЯзыка, ТекущийЯзык) Тогда
					ТекущийЯзык = КодЯзыка;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если ЗначениеЗаполнено(Отбор) Тогда
				ТекущийЯзык = Отбор[0];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Элементы = Форма.Элементы;
	Команды = Форма.Команды;
	
	Если Отбор.Количество() < 2 Тогда
		Возврат;
	КонецЕсли;
	
	Форма.ТекущийЯзык = ТекущийЯзык;
	ДоступныеЯзыки = ДоступныеЯзыки(ИспользоватьРегиональныеПредставленияЯзыков);
	
	ЭтоМобильныйКлиент = ОбщегоНазначения.ЭтоМобильныйКлиент();
	Если Не ЭтоМобильныйКлиент Тогда
		Элементы.Язык.Заголовок = "";
	КонецЕсли;
	
	Для Каждого КодЛокализации Из ДоступныеЯзыки Цикл
		КодЯзыка = СтрРазделить(КодЛокализации, "_", Истина)[0];
		Если Отбор.Найти(КодЯзыка) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ПредставлениеЯзыка = ПредставлениеЯзыка(КодЛокализации);
		Если Не ЗначениеЗаполнено(Элементы.Язык.Заголовок) И КодЯзыка = ТекущийЯзык Тогда
			Элементы.Язык.Заголовок = ПредставлениеЯзыка;
		КонецЕсли;
		
		Команда = Команды.Добавить("Язык_" + КодЛокализации);
		Команда.Действие = "Подключаемый_ПереключитьЯзык";
		Команда.Заголовок = ПредставлениеЯзыка;
		
		КнопкаФормы = Элементы.Добавить(Команда.Имя, Тип("КнопкаФормы"), Элементы.Язык);
		КнопкаФормы.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
		КнопкаФормы.ИмяКоманды = Команда.Имя;
		КнопкаФормы.Заголовок = ПредставлениеЯзыка;
		КнопкаФормы.ТолькоВоВсехДействиях= ЭтоМобильныйКлиент;
	КонецЦикла;
	
КонецПроцедуры

Функция ДоступенАвтоматическийПеревод(КодЯзыка) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность.ПереводТекста") Тогда
		МодульПереводТекстаНаДругиеЯзыки = ОбщегоНазначения.ОбщийМодуль("ПереводТекстаНаДругиеЯзыки");
		Возврат ЭтоДополнительныйЯзыкПечатныхФорм(КодЯзыка) И МодульПереводТекстаНаДругиеЯзыки.ДоступенПереводТекста();
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти
