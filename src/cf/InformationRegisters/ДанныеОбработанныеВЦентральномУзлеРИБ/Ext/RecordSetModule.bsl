﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		// Проверка ОбменДанными.Загрузка не требуется, т.к. работа с данным
		// регистром выполняется во время обмена данными.
		
		Если ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ() И Не ОбновлениеИнформационнойБазы.НеобходимоОбновлениеИнформационнойБазы() Тогда 
			ОтметитьДанныеОбновленыВГлавномУзле();
		КонецЕсли;
		
		Очистить();
		Возврат;
	КонецЕсли;
		
	Если Количество() > 0
		И (Не ЗначениеЗаполнено(ПараметрыСеанса.ПараметрыОбработчикаОбновления.ОчередьОтложеннойОбработки)
			Или ОбщегоНазначения.ЭтоПодчиненныйУзелРИБ()
			Или (ПараметрыСеанса.ПараметрыОбработчикаОбновления.ЗапускатьТолькоВГлавномУзле
			      И Не СтандартныеПодсистемыПовтИсп.ИспользуетсяРИБ())
			Или (Не ПараметрыСеанса.ПараметрыОбработчикаОбновления.ЗапускатьТолькоВГлавномУзле
			      И Не СтандартныеПодсистемыПовтИсп.ИспользуетсяРИБ("СФильтром"))) Тогда
		
		Отказ = Истина;
		ТекстИсключения = НСтр("ru = 'Запись в РегистрСведений.ДанныеОбработанныеВЦентральномУзлеРИБ возможна только при отметке выполнения отложенного обработчика обновления информационной базы, который выполняется только в корневом узле.'");
		ВызватьИсключение ТекстИсключения;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОтметитьДанныеОбновленыВГлавномУзле()
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		
		Объект = ОбщегоНазначения.ОбъектМетаданныхПоИдентификатору(Запись.ОбъектМетаданных, Ложь);
		Если ТипЗнч(Объект) = Тип("ОбъектМетаданных") Тогда // Объект метаданных был удален в конфигурации главного узла.
			ОтметитьВыполнениеОбработки(Запись, Объект);
		КонецЕсли;	
		
		Если ОбменДанными.Отправитель <> Неопределено Тогда // не создание начального образа
			НаборДляРегистрацииОтветаВГлавныйУзел = РегистрыСведений.ДанныеОбработанныеВЦентральномУзлеРИБ.СоздатьНаборЗаписей();
			НаборДляРегистрацииОтветаВГлавныйУзел.Отбор.УзелПланаОбмена.Установить(Запись.УзелПланаОбмена);
			НаборДляРегистрацииОтветаВГлавныйУзел.Отбор.ОбъектМетаданных.Установить(Запись.ОбъектМетаданных);
			НаборДляРегистрацииОтветаВГлавныйУзел.Отбор.Данные.Установить(Запись.Данные);
			НаборДляРегистрацииОтветаВГлавныйУзел.Отбор.Очередь.Установить(Запись.Очередь);
			НаборДляРегистрацииОтветаВГлавныйУзел.Отбор.КлючУникальности.Установить(Запись.КлючУникальности);
			
			ПланыОбмена.ЗарегистрироватьИзменения(ОбменДанными.Отправитель, НаборДляРегистрацииОтветаВГлавныйУзел);
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

Процедура ОтметитьВыполнениеОбработки(Знач Запись, Знач Объект)
	
	ДополнительныеПараметры = ОбновлениеИнформационнойБазы.ДополнительныеПараметрыОтметкиОбработки();
	
	ПолноеИмяОбъектаМетаданных = Объект.ПолноеИмя();
	Если СтрНайти(ПолноеИмяОбъектаМетаданных, "РегистрНакопления") > 0
		Или СтрНайти(ПолноеИмяОбъектаМетаданных, "РегистрБухгалтерии") > 0
		Или СтрНайти(ПолноеИмяОбъектаМетаданных, "РегистрРасчета") > 0 Тогда
		
		ДополнительныеПараметры.ЭтоДвижения       = Истина;
		ДополнительныеПараметры.ПолноеИмяРегистра = ПолноеИмяОбъектаМетаданных;
		ДанныеДляОтметки                          = Запись.Данные;
		
	ИначеЕсли СтрНайти(ПолноеИмяОбъектаМетаданных, "РегистрСведений") > 0 Тогда
		
		Если Объект.РежимЗаписи = Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.Независимый Тогда
			
			МенеджерРегистра = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ПолноеИмяОбъектаМетаданных);
			
			ДанныеДляОтметки = МенеджерРегистра.СоздатьНаборЗаписей();
			ЗначенияОтбора   = Запись.ЗначенияОтборовНезависимогоРегистра.Получить();
			
			Для Каждого КлючЗначение Из ЗначенияОтбора Цикл
				ДанныеДляОтметки.Отбор[КлючЗначение.Ключ].Установить(КлючЗначение.Значение);
			КонецЦикла;
			
		Иначе
			ДополнительныеПараметры.ЭтоДвижения = Истина;
			ДополнительныеПараметры.ПолноеИмяРегистра = ПолноеИмяОбъектаМетаданных;
			ДанныеДляОтметки = Запись.Данные;
		КонецЕсли;
		
	Иначе
		ДанныеДляОтметки = Запись.Данные;
	КонецЕсли;
	
	ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(ДанныеДляОтметки, ДополнительныеПараметры, Запись.Очередь);

КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли