﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Вызывается для записи состояний оригиналов печатных форм в регистр, после печати формы.
//
//	Параметры:
//  ОбъектыПечати - СписокЗначений - список ссылок на объекты печати.
//  СписокПечати - СписокЗначений - список с именами макетов и представлениями печатных форм.
//   Записано - Булево - признак того, что состояние документа записано в регистр.
//
Процедура ЗаписатьСостоянияОригиналовПослеПечати(ОбъектыПечати, СписокПечати, Записано = Ложь) Экспорт

	Если ПолучитьФункциональнуюОпцию("ИспользоватьУчетОригиналовПервичныхДокументов") И Не Пользователи.ЭтоСеансВнешнегоПользователя() Тогда
		УчетОригиналовПервичныхДокументов.ПриОпределенииСпискаПечатныхФорм(ОбъектыПечати, СписокПечати);
		Если СписокПечати.Количество() = 0 Тогда
			Возврат;
		КонецЕсли;
		РегистрыСведений.СостоянияОригиналовПервичныхДокументов.ЗаписатьСостоянияОригиналовДокументаПослеПечатиФормы(ОбъектыПечати, СписокПечати, Записано);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Записывает новое состояние оригинала документа
//	
//	Параметры:
//  ДанныеЗаписи - Массив из Структура - массив содержащий данные об изменяемом состоянии оригинала:
//                 * ОбщееСостояние 						- Булево - Истина, если текущее состояние является общим;
//                 * Ссылка 								- ДокументСсылка - ссылка на документ, для которого необходимо изменить состояние оригинала;
//                 * СостояниеОригиналаПервичногоДокумента - СправочникСсылка.СостоянияОригиналовПервичныхДокументов -
//                                                           текущие состояние оригинала первичного документа;
//                 * ПервичныйДокумент 					- Строка - идентификатор первичного документа. Задается, если данное состояние не является общим;
//                 * Извне 								- Булево - Истина, если первичный документ был добавлен пользователем вручную. Задается, если данное состояние не является общим. 
//               - Структура - структура содержащие данные об изменяемом состоянии оригинала:
//                 * Ссылка - ДокументСсылка - ссылка на документ, для которого необходимо изменить состояние оригинала.
//  ИмяСостояния - Строка - устанавливаемое состояние.
//  Изменено - Булево - Истина, если состояние оригинала документа не повторяется и было записано. Значение по умолчанию
//                      Ложь.
//
Процедура УстановитьНовоеСостояниеОригинала(ДанныеЗаписи, ИмяСостояния, Изменено = Ложь) Экспорт

	УчетОригиналовПервичныхДокументов.УстановитьНовоеСостояниеОригинала(ДанныеЗаписи, ИмяСостояния, Изменено);

КонецПроцедуры

// Возвращает ссылку на документ по штрихкоду табличного документа
//
//	Параметры:
//  Штрихкод - Строка - отсканированный штрихкод документа.
//
Процедура ОбработатьШтрихкод(Штрихкод) Экспорт
	
	УчетОригиналовПервичныхДокументов.ОбработатьШтрихкод(ШтрихКод);

КонецПроцедуры

// Возвращает структуру с данными о текущим общем состоянии оригинала документа по ссылке.
//
//	Параметры:
//  ДокументСсылка - ДокументСсылка - ссылка на документ, для которого необходимо получить сведения о общем состоянии. 
//
//  Возвращаемое значение:
//    Структура - основные сведения о общем состоянии оригинала:
//    * Ссылка - ДокументСсылка - ссылка на документ;
//    * СостояниеОригиналаПервичногоДокумента - СправочникСсылка.СостоянияОригиналовПервичныхДокументов - текущее
//        состояние оригинала документа.
//
Функция СведенияОСостоянииОригиналаПоСсылке(ДокументСсылка) Экспорт

	Возврат УчетОригиналовПервичныхДокументов.СведенияОСостоянииОригиналаПоСсылке(ДокументСсылка);
	
КонецФункции

// Заполняет выпадающий список выбора состояний на форме.
// 
//	Параметры:
//  СписокВыбораСостоянийОригинала - СписокЗначений - состояния оригинала, разрешенные пользователям, и используемые при
//                                                    смене состояния оригинала.
//
Процедура ЗаполнитьСписокВыбораСостоянийОригинала(СписокВыбораСостоянийОригинала) Экспорт
	
	СписокВыбораСостоянийОригинала.Очистить();
	СостоянияОригиналов = УчетОригиналовПервичныхДокументов.ИспользуемыеСостояния();
	
	Для каждого Состояние Из СостоянияОригиналов Цикл

		Если Состояние.Ссылка = Справочники.СостоянияОригиналовПервичныхДокументов.ОригиналПолучен Тогда 
			СписокВыбораСостоянийОригинала.Добавить(Состояние.Наименование,,,БиблиотекаКартинок.СостояниеОригиналаПервичногоДокументаОригиналПолучен);
		ИначеЕсли Состояние.Ссылка = Справочники.СостоянияОригиналовПервичныхДокументов.ФормаНапечатана Тогда
			СписокВыбораСостоянийОригинала.Добавить(Состояние.Наименование,,,БиблиотекаКартинок.СостояниеОригиналаПервичногоДокументаОригиналНеПолучен);
		Иначе
			СписокВыбораСостоянийОригинала.Добавить(Состояние.Наименование);
		КонецЕсли;

	КонецЦикла;
КонецПроцедуры

// Проверяет и возвращает признак того, является ли документ по ссылке документом с учетом оригиналов 
//
//	Возвращаемое значение:
//   см. УчетОригиналовПервичныхДокументов.ВозможностьЗаписиОбъектов
//
Функция ВозможностьЗаписиОбъектов(МассивСсылок) Экспорт
	
	Возврат УчетОригиналовПервичныхДокументов.ВозможностьЗаписиОбъектов(МассивСсылок);

КонецФункции

// Проверяет и возвращает признак того, является ли документ по ссылке документом с учетом оригиналов.
//
//	Параметры:
//  ОбъектСсылка - ДокументСсылка - ссылка на документ, который необходимо проверить.
//
//	Возвращаемое значение:
//  Булево - Истина, если документ является объектом учетом оригиналов.
//
Функция ЭтоОбъектУчета(ОбъектСсылка) Экспорт
	
	Возврат УчетОригиналовПервичныхДокументов.ЭтоОбъектУчета(ОбъектСсылка);

КонецФункции

// Проверяет и возвращает признак того, есть ли у текущего пользователя права на изменение состояния
//
//	Возвращаемое значение:
//  Булево - Истина, если у текущего пользователя есть права на изменение состояния оригинала.
//
Функция ПраваНаИзменениеСостояния() Экспорт
	
	Если ПравоДоступа("Редактирование",Метаданные.РегистрыСведений.СостоянияОригиналовПервичныхДокументов) 
		И ПравоДоступа("Изменение",Метаданные.РегистрыСведений.СостоянияОригиналовПервичныхДокументов) Тогда
		Возврат Истина 
	Иначе
		Возврат Ложь
	КонецЕсли;

КонецФункции

// Возвращает ключ записи регистра общего состояния оригинала документа по ссылке.
//
//	Параметры:
//  ДокументСсылка - ДокументСсылка - ссылка на документ,для которого необходимо получить ключ записи общего состояния.
//
//	Возвращаемое значение:
//  РегистрСведенийКлючЗаписи.СостоянияОригиналовПервичныхДокументов - ключ записи регистра общего состояния оригинала документа.
//
Функция КлючЗаписиОбщегоСостояния(ДокументСсылка) Экспорт

	Возврат УчетОригиналовПервичныхДокументов.КлючЗаписиОбщегоСостояния(ДокументСсылка);

КонецФункции

#КонецОбласти
