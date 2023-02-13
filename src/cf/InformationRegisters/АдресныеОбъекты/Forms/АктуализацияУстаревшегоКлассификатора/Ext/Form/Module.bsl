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
	
	АдресныйКлассификаторСлужебный.ПроверитьНачальноеЗаполнение(); // Инициализация списка регионов
	АутентификацияВыполнена = ДанныеАутентификацииСайтаСохранены();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	Если ВариантыАктуализации = 0 Тогда
		Если НЕ АутентификацияВыполнена Тогда
			// Проходим через форму авторизации принудительно.
			Оповещение = Новый ОписаниеОповещения("ПослеЗапросаАутентификации", ЭтотОбъект);
			АдресныйКлассификаторКлиент.АвторизоватьНаСайтеПоддержкиПользователей(Оповещение, ЭтотОбъект);
			Возврат;
		Иначе
			УстановитьКонстанту();
			Закрыть();
		КонецЕсли;
	Иначе
		Закрыть();
		УстановитьКонстанту();
		АдресныйКлассификаторКлиент.ЗагрузитьАдресныйКлассификатор();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПослеЗапросаАутентификации(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда
		УстановитьКонстанту();
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДанныеАутентификацииСайтаСохранены()
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей") Тогда
		МодульИнтернетПоддержкаПользователей = ОбщегоНазначения.ОбщийМодуль("ИнтернетПоддержкаПользователей");
		Возврат МодульИнтернетПоддержкаПользователей.ЗаполненыДанныеАутентификацииПользователяИнтернетПоддержки();
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

&НаСервереБезКонтекста
Процедура УстановитьКонстанту()
	
	Константы.ИсточникДанныхАдресногоКлассификатора.Установить("Авто");
	АдресныйКлассификаторСлужебный.ОчиститьИнформациюОЗагрузкеВерсий();
	
КонецПроцедуры

#КонецОбласти