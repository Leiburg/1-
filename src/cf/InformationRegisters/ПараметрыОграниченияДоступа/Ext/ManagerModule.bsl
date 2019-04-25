﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Процедура обновляет данные регистра при полном обновлении вспомогательных данных.
// 
// Параметры:
//  ЕстьИзменения - Булево (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(ЕстьИзменения = Неопределено) Экспорт
	
	Если Не УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
		Возврат;
	КонецЕсли;
	
	УправлениеДоступомСлужебный.ДействующиеПараметрыОграниченияДоступа(Неопределено,
		Неопределено, Истина, Ложь, Ложь, ЕстьИзменения);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление информационной базы.

Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию1(Параметры) Экспорт
	
	// Регистрация данных не требуется.
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию1(Параметры) Экспорт
	
	ОписаниеОграниченийДанных = УправлениеДоступомСлужебный.ОписаниеОграниченийДанных();
	ВнешниеПользователиВключены = Константы.ИспользоватьВнешнихПользователей.Получить();
	
	Списки = Новый Массив;
	СпискиДляВнешнихПользователей = Новый Массив;
	Для Каждого КлючИЗначение Из ОписаниеОграниченийДанных Цикл
		Если ЕстьПроверкаПраваНаСписок(КлючИЗначение.Значение.Текст) Тогда
			Списки.Добавить(КлючИЗначение.Ключ);
		КонецЕсли;
		Если ВнешниеПользователиВключены
		   И ЕстьПроверкаПраваНаСписок(КлючИЗначение.Значение.ТекстДляВнешнихПользователей) Тогда
			СпискиДляВнешнихПользователей.Добавить(КлючИЗначение.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыПланирования = УправлениеДоступомСлужебный.ПараметрыПланированияОбновленияДоступа();
	
	ПараметрыПланирования.КлючиДоступаКДанным = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Ложь;
	ПараметрыПланирования.ЭтоПродолжениеОбновления = Истина;
	ПараметрыПланирования.Описание = "ОбработатьДанныеДляПереходаНаНовуюВерсию1";
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(Списки, ПараметрыПланирования);
	
	ПараметрыПланирования.ДляПользователей = Ложь;
	ПараметрыПланирования.ДляВнешнихПользователей = Истина;
	ПараметрыПланирования.Описание = "ОбработатьДанныеДляПереходаНаНовуюВерсию1";
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступа(СпискиДляВнешнихПользователей, ПараметрыПланирования);
	
	Параметры.ОбработкаЗавершена = Истина;
	
КонецПроцедуры

// Для процедуры ОбработатьДанныеДляПереходаНаНовуюВерсию1.
Функция ЕстьПроверкаПраваНаСписок(ТекстОграничения)
	
	Возврат СтрНайти(ВРег(ТекстОграничения), ВРег("ЧтениеСпискаРазрешено")) > 0
		Или СтрНайти(ВРег(ТекстОграничения), ВРег("ИзменениеСпискаРазрешено")) > 0;
	
КонецФункции

#КонецОбласти

#КонецЕсли
