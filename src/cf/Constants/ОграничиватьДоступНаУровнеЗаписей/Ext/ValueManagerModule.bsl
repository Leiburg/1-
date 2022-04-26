﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем ОграничениеДоступаНаУровнеЗаписейВключено; // Флажок изменения значения константы с Ложь на Истина.
                                                 // Используется в обработчике события ПриЗаписи.

Перем ОграничениеДоступаНаУровнеЗаписейИзменено; // Флажок изменения значения константы.
                                                 // Используется в обработчике события ПриЗаписи.

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ОграничениеДоступаНаУровнеЗаписейВключено
		= Значение И НЕ Константы.ОграничиватьДоступНаУровнеЗаписей.Получить();
	
	ОграничениеДоступаНаУровнеЗаписейИзменено
		= Значение <>   Константы.ОграничиватьДоступНаУровнеЗаписей.Получить();
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ОграничениеДоступаНаУровнеЗаписейИзменено Тогда
		ОбновитьПовторноИспользуемыеЗначения();
		Попытка
			УправлениеДоступомСлужебный.ПриИзмененииОграниченияДоступаНаУровнеЗаписей(
				ОграничениеДоступаНаУровнеЗаписейВключено);
		Исключение
			ОбновитьПовторноИспользуемыеЗначения();
			ВызватьИсключение;
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования.
Процедура ЗарегистрироватьИзменениеПриЗагрузке(ЭлементДанных) Экспорт
	
	СтароеЗначение = Константы.ОграничиватьДоступНаУровнеЗаписей.Получить();
	
	Если СтароеЗначение = ЭлементДанных.Значение Тогда
		Возврат;
	КонецЕсли;
	
	ОграничениеДоступаНаУровнеЗаписейВключено = СтароеЗначение И Не ЭлементДанных.Значение;
	
	Справочники.ГруппыДоступа.ЗарегистрироватьСсылки("ОграничиватьДоступНаУровнеЗаписей",
		ОграничениеДоступаНаУровнеЗаписейВключено);
	
КонецПроцедуры

// Только для внутреннего использования.
Процедура ОбработатьИзменениеЗарегистрированноеПриЗагрузке() Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		// Изменение настроек прав в АРМ заблокированы и не загружаются в область данных.
		Возврат;
	КонецЕсли;
	
	Изменения = Справочники.ГруппыДоступа.ЗарегистрированныеСсылки("ОграничиватьДоступНаУровнеЗаписей");
	Если Изменения.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	УправлениеДоступомСлужебный.ПриИзмененииОграниченияДоступаНаУровнеЗаписей(Изменения[0]);
	
	Справочники.ГруппыДоступа.ЗарегистрироватьСсылки("ОграничиватьДоступНаУровнеЗаписей", Null);
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли